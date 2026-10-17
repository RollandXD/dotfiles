#!/usr/bin/env python3
"""原生 GTK 选词小窗：客户端先抓取文字，D-Bus 单实例只接收快照。"""
from __future__ import annotations

from collections import OrderedDict
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import re
import selectors
import subprocess
import sys
import tempfile
import threading
import time

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
gi.require_version('Gst', '1.0')
gi.require_version('GstAudio', '1.0')
from gi.repository import Gdk, Gio, GLib, Gst, GstAudio, Gtk, Pango

from lookup_backend import (DATA, Dictionary, LookupError, MAX_TEXT, ROOT, STATE, level_audio, normalize,
                            single_word, translate)

APP_ID = os.environ.get('ENGLISH_LOOKUP_APP_ID', 'io.github.rolland.EnglishLookup')
NO_SELECTION = '无选区'  # 客户端没抓到选区时的来源前缀，小窗改读剪贴板。
CLIPBOARD_FALLBACK = '待确认 · 剪贴板（未选中文字）'
REPEAT = '待确认 · 与上次相同的桌面选区'
PASSWORD_HINT = 'x-kde-passwordManagerHint'  # KeePassXC 等复制密码时附带的标记。
AUTO_PHRASE = re.compile(r"[A-Za-z0-9 '’,.;:!?()\-\"“”]{1,300}")


def plain_english(text):
    """桌面选区可免确认的范围：纯字母单词，或不含密钥常见符号的短英文。"""
    if ' ' not in text:
        return single_word(text)
    return bool(AUTO_PHRASE.fullmatch(text) and re.search(r'[A-Za-z]{2}', text))


class Voice:
    IDLE = 90  # 秒；模型常驻约 500 MB，闲置即退出，下次合成冷启动约 2 秒。

    def __init__(self):
        self.process = None
        self.lock = threading.Lock()
        self.timer = None

    def synthesize(self, text, path, voice):
        with self.lock:
            if self.timer:
                self.timer.cancel()
            if self.process is None or self.process.poll() is not None:
                python = DATA / 'venv/bin/python'
                if not python.exists():
                    raise LookupError('未安装合成环境，请运行 install-english-lookup-models。')
                self.process = subprocess.Popen([str(python),
                                                 str(ROOT / 'voice_worker.py')],
                                                stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                                stderr=subprocess.DEVNULL, text=True, bufsize=1)
            p = self.process
            try:
                p.stdin.write(json.dumps({'text': text, 'path': str(path), 'voice': voice}) + '\n')
                p.stdin.flush()
                selector = selectors.DefaultSelector()
                selector.register(p.stdout, selectors.EVENT_READ)
                deadline = time.monotonic() + 30
                with selector:
                    while time.monotonic() < deadline:
                        if not selector.select(max(0, deadline - time.monotonic())):
                            break
                        line = p.stdout.readline()
                        if not line:
                            break
                        try:
                            reply = json.loads(line)
                        except ValueError:
                            continue  # 第三方初始化提示不进入应用日志。
                        if reply.get('ok') and path.exists():
                            self.timer = threading.Timer(self.IDLE, self.idle_stop)
                            self.timer.daemon = True
                            self.timer.start()
                            return path
                        raise LookupError('Kokoro 合成失败，请重试或选择另一声音。')
                raise LookupError('Kokoro 初始化或合成超时，请重试。')
            except (OSError, LookupError):
                self.stop()
                raise LookupError('Kokoro 初始化或合成失败，请重试。') from None

    def idle_stop(self):
        # 与 synthesize 共用锁：合成进行中不会被杀掉。
        with self.lock:
            self.stop()

    def stop(self):
        if self.timer:
            self.timer.cancel()
            self.timer = None
        p, self.process = self.process, None
        if p and p.poll() is None:
            p.kill()
            p.wait(timeout=5)


class LookupApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id=APP_ID)
        self.generation = 0
        self.audio_ticket = 0
        self.text = ''
        self.result_text = ''
        self.prons = []
        self.futures = []
        self.closed = False
        self.window = None
        self.drop_count = 0
        self.audio_state = ''
        self.audio_finished = 0
        self.request_count = 0
        self.last_selection = ''
        self.updating_prons = False
        self.api_pool = ThreadPoolExecutor(max_workers=2)
        self.dict_pool = ThreadPoolExecutor(max_workers=2)
        self.voice_pool = ThreadPoolExecutor(max_workers=1)
        self.voice = Voice()
        self.results = OrderedDict()
        self.temp = tempfile.TemporaryDirectory(prefix='english-lookup-')
        self.dictionary = Dictionary(STATE / 'pronunciation-cache')
        self.settings_path = STATE / 'lookup-settings.json'
        try:
            self.settings = json.loads(self.settings_path.read_text())
        except (OSError, ValueError):
            self.settings = {}
        self.voice_name = self.settings.get('voice', 'af_heart')
        if self.voice_name not in ('af_heart', 'af_bella'):
            self.voice_name = 'af_heart'
        self.auto = self.settings.get('auto', True)
        volume = self.settings.get('volume', 80)
        self.volume = volume if isinstance(volume, (int, float)) and 0 <= volume <= 100 else 80
        self.last_clipboard = ''

    def do_startup(self):
        Gtk.Application.do_startup(self)
        self.hold()  # 关闭小窗后保留单实例，随后查询无需重载模型。
        Gst.init(None)
        self.player = Gst.ElementFactory.make('playbin', 'english-lookup-player')
        if not self.player:
            raise LookupError('系统缺少 GStreamer playbin。')
        self.player.set_property('video-sink', Gst.ElementFactory.make('fakesink', None))
        self.apply_volume()
        bus = self.player.get_bus()
        bus.add_signal_watch()
        bus.connect('message', self.on_media)
        action = Gio.SimpleAction.new('lookup', GLib.VariantType.new('(ss)'))
        action.connect('activate', lambda _, p: self.lookup(*p.unpack()))
        self.add_action(action)
        for name, callback in [('close', self.hide), ('replay', self.play),
                               ('submit', self.submit), ('quit', self.shutdown)]:
            action = Gio.SimpleAction.new(name, None)
            action.connect('activate', lambda _, p, cb=callback: cb())
            self.add_action(action)
        self.diagnostic = Gio.SimpleAction.new_stateful('diagnostics', None, GLib.Variant('s', '{}'))
        self.add_action(self.diagnostic)
        self.set_accels_for_action('app.close', ['Escape', '<Control>w'])
        self.set_accels_for_action('app.replay', ['<Control>r'])
        self.set_accels_for_action('app.submit', ['<Control>Return'])
        self.build_window()
        GLib.timeout_add_seconds(30, self.idle_check)
        self.last_use = time.monotonic()

    def do_activate(self):
        self.window.present()

    def build_window(self):
        self.window = Gtk.ApplicationWindow(application=self, title='英文随查')
        self.window.set_default_size(680, 430)
        self.window.connect('close-request', lambda _: (self.hide(), True)[1])
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        for name in ('top', 'bottom', 'start', 'end'):
            getattr(box, 'set_margin_' + name)(18)
        self.window.set_child(box)
        header = Gtk.Box(spacing=10)
        title = Gtk.Label(label='英文随查', xalign=0, hexpand=True)
        title.add_css_class('title-2')
        header.append(title)
        self.auto_button = Gtk.CheckButton(label='单词自动发音', active=self.auto)
        self.auto_button.connect('toggled', self.auto_changed)
        header.append(self.auto_button)
        close = Gtk.Button(icon_name='window-close-symbolic', tooltip_text='关闭 · Esc')
        close.connect('clicked', lambda _: self.hide())
        header.append(close)
        box.append(header)
        self.origin = Gtk.Label(label='Super+A 选词查询 · 已复制的文字点“粘贴并查询”', xalign=0)
        self.origin.add_css_class('dim-label')
        self.origin.set_wrap(True)
        box.append(self.origin)
        self.source = Gtk.TextView(wrap_mode=Gtk.WrapMode.WORD_CHAR)
        keys = Gtk.EventControllerKey()
        keys.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        keys.connect('key-pressed', self.source_key)
        self.source.add_controller(keys)
        self.source.set_top_margin(8)
        self.source.set_bottom_margin(8)
        self.source.set_left_margin(10)
        self.source.set_right_margin(10)
        scroll = Gtk.ScrolledWindow(min_content_height=65, max_content_height=100)
        scroll.set_child(self.source)
        scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        frame = Gtk.Frame()
        frame.set_child(scroll)
        box.append(frame)
        tools = Gtk.Box(spacing=8)
        query = Gtk.Button(label='查询', tooltip_text='Enter')
        query.add_css_class('suggested-action')
        query.connect('clicked', lambda _: self.submit())
        tools.append(query)
        paste = Gtk.Button(label='粘贴并查询')
        paste.connect('clicked', self.paste)
        tools.append(paste)
        self.play_button = Gtk.Button(label='▶ 美音', tooltip_text='重播 · Ctrl+R')
        self.play_button.connect('clicked', lambda _: self.play())
        tools.append(self.play_button)
        stop = Gtk.Button(label='停止')
        stop.connect('clicked', lambda _: self.stop_audio())
        tools.append(stop)
        self.voices = Gtk.DropDown.new_from_strings(['Heart · 美音', 'Bella · 美音'])
        self.voices.set_selected(0 if self.voice_name == 'af_heart' else 1)
        self.voices.set_tooltip_text('词典没有录音或朗读句子时使用')
        self.voices.connect('notify::selected', self.voice_changed)
        tools.append(self.voices)
        tools.append(Gtk.Image(icon_name='audio-volume-medium-symbolic', margin_start=6))
        self.volume_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 5)
        self.volume_scale.set_value(self.volume)
        self.volume_scale.set_size_request(110, -1)
        self.volume_scale.set_tooltip_text('音量')
        self.volume_scale.connect('value-changed', self.volume_changed)
        tools.append(self.volume_scale)
        box.append(tools)
        self.pron_dropdown = Gtk.DropDown.new_from_strings(['正在查找词典美音…'])
        self.pron_dropdown.connect('notify::selected', self.pron_changed)
        box.append(self.pron_dropdown)
        self.result = Gtk.Label(label='选中英文，或粘贴到上方输入框。', xalign=0, yalign=0,
                                selectable=True, wrap=True, hexpand=True)
        self.result.set_wrap_mode(Pango.WrapMode.WORD_CHAR)
        self.result.add_css_class('lookup-result')
        result_scroll = Gtk.ScrolledWindow(vexpand=True, min_content_height=125)
        result_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        result_scroll.set_child(self.result)
        box.append(result_scroll)
        self.audio_status = Gtk.Label(label='单词优先词典录音 · 句子使用 Kokoro', xalign=0, wrap=True)
        self.audio_status.add_css_class('dim-label')
        box.append(self.audio_status)
        footer = Gtk.Label(label='Esc 关闭 · Enter 查询 · Shift+Enter 换行 · Ctrl+R 重播', xalign=0)
        footer.add_css_class('dim-label')
        box.append(footer)
        provider = Gtk.CssProvider()
        provider.load_from_data(b'.lookup-result { font-size: 18px; } textview { font-size: 16px; }')
        Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), provider,
                                                  Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    def update_diagnostics(self, audio=None):
        if audio is not None:
            self.audio_state = audio
        # 验证接口仅输出摘要，不暴露用户文本或凭据。
        self.diagnostic.set_state(GLib.Variant('s', json.dumps({
            'generation': self.generation, 'source_hash': hashlib.sha256(self.text.encode()).hexdigest(),
            'result_hash': hashlib.sha256(self.result_text.encode()).hexdigest(),
            'result_length': len(self.result_text), 'pronunciations': len(self.prons),
            'visible': self.window.get_visible(), 'discarded': self.drop_count, 'audio': self.audio_state,
            'audio_finished': self.audio_finished, 'requests': self.request_count})))

    def schedule(self, pool, work, callback, generation=None, ticket=None):
        generation = self.generation if generation is None else generation
        def run():
            if generation != self.generation or (ticket is not None and ticket != self.audio_ticket):
                return None
            return work()
        future = pool.submit(run)
        self.futures.append(future)
        def completed(f):
            def deliver():
                if self.closed or generation != self.generation or (ticket is not None and ticket != self.audio_ticket):
                    self.drop_count += 1
                    self.update_diagnostics()
                    return False
                if f.cancelled():
                    return False
                try:
                    value = f.result()
                    if value is not None:
                        callback(value, None)
                except Exception as error:
                    callback(None, str(error) if isinstance(error, LookupError) else '操作失败，可重试。')
                self.futures = [x for x in self.futures if not x.done()]
                return False
            GLib.idle_add(deliver)
        future.add_done_callback(completed)

    def invalidate(self):
        self.generation += 1
        self.stop_audio()
        for f in self.futures:
            f.cancel()
        self.futures = []

    def lookup(self, text, origin):
        self.last_use = time.monotonic()
        self.invalidate()
        self.prons = []
        self.result_text = ''
        self.window.present()
        self.source.get_buffer().set_text(text)
        self.origin.set_text(origin)
        try:
            self.text = normalize(text)
        except LookupError as error:
            self.text = ''
            self.result.set_text(str(error))
            self.update_diagnostics()
            return
        self.pron_dropdown.set_model(Gtk.StringList.new(['等待查询']))
        self.pron_dropdown.set_sensitive(False)
        self.play_button.set_sensitive(bool(self.text))
        if origin.startswith(NO_SELECTION) or (origin.startswith('待确认') and not self.text
                                                and origin != CLIPBOARD_FALLBACK):
            self.result.set_text('没有选中文字，正在读取剪贴板…')
            self.read_clipboard(fallback=True)
            self.update_diagnostics()
            return
        if origin.startswith('待确认') and self.text:
            # 选区换了新的普通英文就直接查；与上次相同（可能是过期选区）或像密钥/代码才确认。
            if origin == CLIPBOARD_FALLBACK:
                fresh = plain_english(self.text)
            elif origin == REPEAT:
                fresh = False
            else:
                stale = self.text == self.last_selection
                self.last_selection = self.text
                if stale:
                    # 选区没变：剪贴板有新内容就查剪贴板，否则按重复选区处理。
                    self.result.set_text('选区与上次相同，正在检查剪贴板…')
                    self.read_clipboard(fallback=True, unless_seen=True)
                    self.update_diagnostics()
                    return
                fresh = plain_english(self.text)
            if fresh or self.text in self.results:
                origin = origin.removeprefix('待确认 · ')
                self.origin.set_text(origin)
        if origin.startswith('待确认') and self.text:
            self.result.set_text('请核对上方文字，按 Enter 查询。\n也可先复制，再点“粘贴并查询”。')
            self.audio_status.set_text('此应用无法确认选区是否仍有效，确认后才发送请求。')
            self.play_button.set_sensitive(False)
            self.update_diagnostics()
            return
        if not self.text:
            self.result.set_text('没有读取到文字。请选中英文，或复制后再按 Super+A。')
            self.audio_status.set_text('')
            self.update_diagnostics()
            return
        self.result.set_text('正在查询…')
        self.audio_status.set_text('正在查找词典美音…' if single_word(self.text) else '点击美音朗读句子')
        snapshot = self.text
        if snapshot in self.results:
            self.set_translation(self.results[snapshot], None)
        else:
            self.request_count += 1
            self.schedule(self.api_pool, lambda: translate(snapshot), self.set_translation)
        if single_word(snapshot):
            self.schedule(self.dict_pool, lambda: self.dictionary.pronunciations(snapshot), self.set_prons)
        else:
            self.pron_dropdown.set_model(Gtk.StringList.new(['句子 · Kokoro 美音']))
        self.update_diagnostics()

    def set_translation(self, value, error):
        self.result_text = value or error
        self.result.set_text(self.result_text)
        if value:
            self.results[self.text] = value
            self.results.move_to_end(self.text)
            while len(self.results) > 100:
                self.results.popitem(last=False)
        self.update_diagnostics()

    def set_prons(self, values, error):
        self.prons = values or []
        labels = [f'{p.ipa}  {p.pos}  · {p.source}' for p in self.prons]
        self.updating_prons = True
        self.pron_dropdown.set_model(Gtk.StringList.new(labels or ['未找到词典录音 · Kokoro 美音']))
        self.pron_dropdown.set_selected(0)
        self.updating_prons = False
        self.pron_dropdown.set_sensitive(len(labels) > 1)
        self.audio_status.set_text('词典美音已就绪' if values else '没有词典录音，将使用 Kokoro 合成美音')
        self.update_diagnostics()
        if self.auto and self.window.get_visible():
            self.play()

    def play(self):
        if not self.text:
            return
        self.last_use = time.monotonic()
        self.stop_audio()
        ticket = self.audio_ticket
        text, voice = self.text, self.voice_name
        selected = self.pron_dropdown.get_selected()
        pron = self.prons[selected] if selected < len(self.prons) else None
        if not pron and len(text) > 600:
            self.audio_status.set_text('朗读超过 600 字，请缩小选区。')
            return
        self.audio_status.set_text('正在加载美音…')
        path = Path(self.temp.name) / (hashlib.sha256((voice + '\0' + text).encode()).hexdigest() + '.wav')
        def work():
            if pron:
                try:
                    return self.dictionary.audio_file(pron), pron.source
                except (OSError, LookupError, subprocess.TimeoutExpired):
                    pass
            if ticket != self.audio_ticket or self.closed:
                return None
            if not path.exists():
                raw = path.with_suffix('.raw.wav')
                self.voice.synthesize(text, raw, voice)
                level_audio(raw, path)
                raw.unlink(missing_ok=True)
            return path, 'Kokoro · ' + voice + ' · 合成美音'
        def ready(value, error):
            if error:
                self.audio_status.set_text(error)
                self.update_diagnostics('error')
                return
            path, source = value
            self.player.set_property('uri', path.as_uri())
            self.player.set_state(Gst.State.PLAYING)
            self.audio_status.set_text('播放中 · ' + source)
            self.update_diagnostics('playing')
        self.schedule(self.voice_pool, work, ready, ticket=ticket)

    def stop_audio(self):
        self.audio_ticket += 1
        self.audio_state = 'stopped'
        if hasattr(self, 'player'):
            self.player.set_state(Gst.State.NULL)
            # 旧媒体的 EOS/ERROR 不得影响下一次播放。
            bus = self.player.get_bus()
            bus.set_flushing(True)
            bus.set_flushing(False)
        if hasattr(self, 'audio_status'):
            self.audio_status.set_text('已停止')


    def on_media(self, bus, message):
        if message.type == Gst.MessageType.EOS:
            self.audio_finished += 1
            self.player.set_state(Gst.State.NULL)
            self.audio_status.set_text(self.audio_status.get_text().replace('播放中', '已播放'))
            self.update_diagnostics('finished')
        elif message.type == Gst.MessageType.ERROR:
            self.player.set_state(Gst.State.NULL)
            self.audio_status.set_text('音频播放失败，请检查输出设备后重播。')
            self.update_diagnostics('error')

    def submit(self):
        b = self.source.get_buffer()
        self.lookup(b.get_text(b.get_start_iter(), b.get_end_iter(), False), '手动输入')

    def paste(self, _):
        self.read_clipboard()

    def read_clipboard(self, fallback=False, unless_seen=False):
        """fallback 用于没选中文字时自动读取，需经过与桌面选区相同的确认规则。"""
        generation = self.generation
        selection = self.text
        clipboard = self.window.get_display().get_clipboard()
        def received(c, result):
            if self.generation != generation:
                return
            try:
                text = c.read_text_finish(result) or ''
            except GLib.Error:
                text = ''
            seen = normalize_or_empty(text) in ('', self.last_clipboard)
            self.last_clipboard = normalize_or_empty(text)
            if unless_seen and seen:
                # 选区没变、剪贴板也没新内容：按原规则处理这次重复的选区。
                self.show_repeat(selection)
            elif fallback:
                self.lookup(text, CLIPBOARD_FALLBACK)
            else:
                self.lookup(text, '剪贴板 · 明确复制的文字')
        def read():
            if self.generation != generation:
                return
            if fallback and clipboard.get_formats().contain_mime_type(PASSWORD_HINT):
                self.result.set_text('剪贴板内容被密码管理器标记为密码，不读取。')
                return
            clipboard.read_text_async(None, received)
        self.when_active(read)

    def when_active(self, callback):
        # Wayland 在窗口获得键盘焦点时才把剪贴板交给本程序；最多等 1 秒。
        if self.window.is_active():
            callback()
            return
        state = {}
        def fire(*_):
            if state.pop('pending', False):
                self.window.disconnect(state['handler'])
                if state['timer']:
                    GLib.source_remove(state['timer'])
                callback()
            return False
        state['pending'] = True
        state['handler'] = self.window.connect('notify::is-active', lambda w, _: w.is_active() and fire())
        state['timer'] = GLib.timeout_add(1000, lambda: (state.update(timer=0), fire())[1])

    def show_repeat(self, text):
        # 已查过的直接显示缓存；没查过的仍需确认（可能是早已失效的旧选区）。
        self.lookup(text, REPEAT)

    def volume_changed(self, scale):
        self.volume = round(scale.get_value())
        self.apply_volume()
        self.save_settings()

    def apply_volume(self):
        # 滑块按人耳感受的立方曲线换算成线性增益。
        linear = GstAudio.StreamVolume.convert_volume(GstAudio.StreamVolumeFormat.CUBIC,
                                                      GstAudio.StreamVolumeFormat.LINEAR,
                                                      self.volume / 100)
        self.player.set_property('volume', linear)

    def pron_changed(self, _, prop):
        # 用户切换读法即播放所选读音；程序刷新列表时不触发。
        if self.prons and not self.updating_prons:
            self.play()

    def source_key(self, _, keyval, keycode, state):
        # 输入法组字时按键由 fcitx5 先处理，到这里的 Enter 都是提交。
        if keyval in (Gdk.KEY_Return, Gdk.KEY_KP_Enter) and not state & (
                Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK):
            self.submit()
            return True
        return False

    def auto_changed(self, button):
        self.auto = button.get_active()
        self.save_settings()

    def voice_changed(self, dropdown, prop):
        self.voice_name = ('af_heart', 'af_bella')[dropdown.get_selected()]
        self.stop_audio()
        self.save_settings()

    def save_settings(self):
        self.settings_path.write_text(json.dumps({'auto': self.auto, 'voice': self.voice_name,
                                                  'volume': self.volume}))

    def hide(self):
        self.invalidate()
        self.window.set_visible(False)
        self.update_diagnostics()

    def idle_check(self):
        if not self.window.get_visible() and time.monotonic() - self.last_use > 600:
            self.shutdown()
            return False
        return True

    def shutdown(self):
        self.closed = True
        self.invalidate()
        self.voice.stop()
        self.quit()

    def cleanup(self):
        self.voice.stop()
        for pool in (self.api_pool, self.dict_pool, self.voice_pool):
            pool.shutdown(wait=False, cancel_futures=True)
        # 后台工作结束前保留临时文件，由 TemporaryDirectory 生命周期清理。


def normalize_or_empty(text):
    try:
        return normalize(text)
    except LookupError:
        return ''


def captured_text(mode):
    if mode == 'stdin':
        return sys.stdin.read(MAX_TEXT * 4 + 1), '编辑器选区 · 直接传入'
    if mode == 'open':
        return '', '输入或粘贴英文，Enter 查询'
    if mode == 'selection':
        try:
            windows = json.loads(subprocess.check_output(['niri', 'msg', '--json', 'windows'], timeout=1))
            focused = next((w for w in windows if w.get('is_focused')), {})
        except (OSError, ValueError, subprocess.TimeoutExpired):
            focused = {}
        if focused.get('app_id') == APP_ID:
            return '', 'close-window'
        # niri 对没有 app_id 的窗口返回 null。
        if (focused.get('app_id') or '').lower() == 'kitty':
            pid = focused.get('pid')
            socket = Path(os.environ.get('XDG_RUNTIME_DIR', '/run/user/' + str(os.getuid()))) / f'english-lookup-kitty-{pid}'
            if not socket.exists():
                return '', NO_SELECTION + ' · 终端选区接口未生效（新开 Kitty 窗口后可用）'
            command = ['kitten', '@', '--to', 'unix:' + str(socket), '--use-password', 'never',
                       'get-text', '--extent', 'selection', '--match', 'state:focused']
            try:
                p = subprocess.run(command, capture_output=True, timeout=2)
                if p.returncode == 0 and p.stdout.strip():
                    return p.stdout.decode(errors='replace'), 'Kitty 当前选区'
                if p.returncode == 0:
                    return '', NO_SELECTION + ' · Kitty'
            except (OSError, subprocess.TimeoutExpired):
                pass
            return '', NO_SELECTION + ' · 终端选区读取失败'
    command = ['wl-paste', '--type', 'text', '--no-newline']
    if mode == 'selection':
        command.append('--primary')
    try:
        p = subprocess.run(command, capture_output=True, timeout=2)
        text = p.stdout.decode('utf-8', errors='replace') if not p.returncode else ''
        if mode == 'selection':
            return text, ('待确认 · 当前应用的桌面选区' if text.strip() else NO_SELECTION + ' · 当前应用')
        return text, '剪贴板 · 明确复制的文字'
    except (OSError, subprocess.TimeoutExpired):
        return '', NO_SELECTION + ' · 未能读取选区' if mode == 'selection' else '未能读取剪贴板'


def main():
    os.umask(0o077)
    mode = sys.argv[1] if len(sys.argv) > 1 else 'selection'
    if mode not in ('selection', 'clipboard', 'stdin', 'open', 'quit', 'status'):
        print('用法：english-lookup {selection|clipboard|stdin|open|quit|status}', file=sys.stderr)
        return 2
    # 在 GTK 注册、窗口激活之前抓取并冻结选区；不自动回退另一剪贴板。
    text, origin = captured_text(mode) if mode not in ('quit', 'status') else ('', '')
    # 远程客户端直接调用 D-Bus，不创建 GTK 实例、线程池或缓存目录。
    connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    try:
        owner = connection.call_sync('org.freedesktop.DBus', '/org/freedesktop/DBus',
                                     'org.freedesktop.DBus', 'NameHasOwner',
                                     GLib.Variant('(s)', (APP_ID,)), None,
                                     Gio.DBusCallFlags.NONE, 2000, None).unpack()[0]
        path = '/' + APP_ID.replace('.', '/')
        if owner:
            if mode == 'status':
                state = connection.call_sync(APP_ID, path, 'org.gtk.Actions', 'Describe',
                                             GLib.Variant('(s)', ('diagnostics',)), None,
                                             Gio.DBusCallFlags.NONE, 2000, None).unpack()
                print(state[0][2][0])
            else:
                action = 'quit' if mode == 'quit' else 'close' if origin == 'close-window' else 'lookup'
                args = [GLib.Variant('(ss)', (text, origin))] if action == 'lookup' else []
                connection.call_sync(APP_ID, path, 'org.gtk.Actions', 'Activate',
                                     GLib.Variant('(sava{sv})', (action, args, {})), None,
                                     Gio.DBusCallFlags.NONE, 2000, None)
            return 0
    except GLib.Error:
        if mode in ('status', 'quit'):
            print('小窗未运行。')
            return 0
    if mode in ('status', 'quit'):
        print('小窗未运行。')
        return 0
    app = LookupApp()
    app.register(None)
    # 同时首次启动的客户端仍由 GApplication 的唯一性保证合并。
    if app.get_is_remote():
        app.activate_action('lookup', GLib.Variant('(ss)', (text, origin)))
        return 0
    app.lookup(text, origin)
    try:
        return app.run([sys.argv[0]])
    finally:
        app.cleanup()


if __name__ == '__main__':
    raise SystemExit(main())
