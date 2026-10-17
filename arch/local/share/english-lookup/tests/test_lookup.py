"""回归重点：错误选区、英美音混用、超时、过期结果和音频回调。"""
from concurrent.futures import ThreadPoolExecutor
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import time
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import urllib.error

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
sys.path.insert(0, str(Path(__file__).resolve().parents[4] / 'config/kitty'))  # kitty_selection_auth.py
from lookup_backend import (CambridgeParser, Dictionary, credentials, level_audio, loudness, LookupError,
                            normalize, single_word, translate)
from lookup_app import (CLIPBOARD_FALLBACK, NO_SELECTION, LookupApp, Voice, captured_text,
                        plain_english)
from kitty_selection_auth import is_cmd_allowed
from gi.repository import Gio, GLib


class TextTests(unittest.TestCase):
    def test_pdf_and_code(self):
        self.assertEqual(normalize('The appli-\ncation\u00ad uses cached_result.\n'), 'The application uses cached_result.')
        self.assertEqual(normalize('fall-back = cache_value'), 'fall-back = cache_value')

    def test_word_detection_and_limit(self):
        self.assertTrue(single_word('ephemeral'))
        self.assertTrue(single_word("don't"))
        self.assertFalse(single_word('cached_result'))
        with self.assertRaises(LookupError):
            normalize('x' * 6001)

    def test_selected_word_keeps_dictionary_mode(self):
        for raw in ['cache,', '“cache”', '(ephemeral).', "'queue'", ' read! ']:
            self.assertTrue(single_word(normalize(raw)), raw)
        self.assertEqual(normalize("don't."), "don't")
        self.assertEqual(normalize('Hello, world.'), 'Hello, world.')
        self.assertEqual(normalize('...'), '...')

    def test_only_plain_english_skips_confirmation(self):
        for text in ['ephemeral', 'The cache is warm.', 'HTTP 404 means not found']:
            self.assertTrue(plain_english(text), text)
        for text in ['hunter2', 'sk-abc123', 'a$b c', 'user@example.com', 'x = y + 1', '1 2 3', 'a' * 301 + ' b']:
            self.assertFalse(plain_english(text), text)

    def test_empty_clipboard_is_not_replaced(self):
        with patch('lookup_app.subprocess.run', return_value=SimpleNamespace(stdout=b'', returncode=1)) as run:
            text, _ = captured_text('clipboard')
        self.assertEqual(text, '')
        self.assertEqual(run.call_count, 1)
        self.assertNotIn('--primary', run.call_args.args[0])

    def test_kitty_without_socket_does_not_read_clipboard(self):
        with patch('lookup_app.subprocess.check_output', return_value=b'[{"app_id":"kitty","pid":999999999,"is_focused":true}]'), \
             patch('lookup_app.subprocess.run') as run:
            text, _ = captured_text('selection')
        self.assertEqual(text, '')
        run.assert_not_called()

    def test_empty_primary_is_marked_no_selection(self):
        with patch('lookup_app.subprocess.check_output', return_value=b'[{"app_id":"firefox","is_focused":true}]'), \
             patch('lookup_app.subprocess.run', return_value=SimpleNamespace(stdout=b'  ', returncode=0)):
            text, origin = captured_text('selection')
        self.assertTrue(origin.startswith(NO_SELECTION))

    def test_window_without_app_id_uses_primary(self):
        with patch('lookup_app.subprocess.check_output', return_value=b'[{"app_id":null,"is_focused":true}]'), \
             patch('lookup_app.subprocess.run', return_value=SimpleNamespace(returncode=0, stdout=b'cache')):
            self.assertEqual(captured_text('selection'), ('cache', '待确认 · 当前应用的桌面选区'))

    def test_kitty_empty_selection_does_not_fall_back(self):
        with patch('lookup_app.subprocess.check_output', return_value=b'[{"app_id":"kitty","pid":10,"is_focused":true}]'), \
             patch('lookup_app.Path.exists', return_value=True), \
             patch('lookup_app.subprocess.run', return_value=SimpleNamespace(stdout=b'', returncode=0)) as run:
            text, _ = captured_text('selection')
        self.assertEqual(text, '')
        self.assertEqual(run.call_count, 1)
        self.assertEqual(run.call_args.args[0][0], 'kitten')


class DictionaryTests(unittest.TestCase):
    def test_pairing_accent_and_related_words(self):
        html = '''<div><span class="hw dhw">read</span><span class="pos dpos">verb</span>
        <span class="uk dpron-i"><audio><source src="/us/media/english/uk_pron/read.mp3"/></audio><span class="ipa">riːd</span></span>
        <span class="us dpron-i"><audio><source src="/us/media/english/us_pron/read1.mp3"/></audio><span class="ipa">riːd</span></span>
        <span class="us dpron-i"><audio><source src="/us/media/english/us_pron/read2.mp3"/></audio><span class="ipa">red</span></span>
        <span class="hw dhw">reader</span><span class="us dpron-i"><audio><source src="/us/media/english/us_pron/reader.mp3"/></audio><span class="ipa">reader</span></span></div>'''
        p = CambridgeParser('read');p.feed(html)
        self.assertEqual([x['ipa'] for x in p.results], ['riːd', 'red'])
        self.assertTrue(all('/us_pron/' in x['audio'] for x in p.results))

    def test_inflected_word_falls_back_to_lemma(self):
        html = '''<div><span class="hw dhw">cache</span><span class="pos dpos">noun</span>
        <span class="us dpron-i"><audio><source src="/us/media/english/us_pron/cache.mp3"/></audio><span class="ipa">kæʃ</span></span>
        <span class="hw dhw">cache out</span><span class="us dpron-i"><audio><source src="/us/media/english/us_pron/x.mp3"/></audio><span class="ipa">x</span></span></div>'''
        with tempfile.TemporaryDirectory() as tmp, patch('lookup_backend.get_bytes', return_value=html.encode()):
            found = Dictionary(Path(tmp)).pronunciations('caches')
        self.assertEqual([(p.ipa, p.pos) for p in found], [('/kæʃ/', 'noun · 原形 cache')])

    def test_remote_interface_only_allows_selection(self):
        allowed = {'cmd': 'get-text', 'payload': {'extent': 'selection', 'match': 'state:focused'}}
        self.assertTrue(is_cmd_allowed(allowed, None, True, {}))
        for cmd in ['launch', 'send-text', 'close-window', 'ls']:
            self.assertFalse(is_cmd_allowed({'cmd': cmd, 'payload': {}}, None, True, {}))
        self.assertFalse(is_cmd_allowed(allowed, None, False, {}))
        for k, v in [('extent', 'screen'), ('clear_selection', True), ('match', 'all')]:
            p = dict(allowed['payload']);p[k] = v
            self.assertFalse(is_cmd_allowed({'cmd': 'get-text', 'payload': p}, None, True, {}))


class ApiTests(unittest.TestCase):
    def test_generated_ipa_is_not_displayed(self):
        content = json.dumps({'meanings': ['v. 阅读'], 'technical': '读取数据（现在时/riːd/，过去式/red/）'})
        response = io.BytesIO(json.dumps({'choices': [{'message': {'content': content}}]}).encode())
        with patch('lookup_backend.credentials', return_value=('TEST_CREDENTIAL', 'deepseek-flash')), \
             patch('lookup_backend.urllib.request.urlopen', return_value=response):
            self.assertEqual(translate('read'), 'v. 阅读\n技术：读取数据')

    def test_fast_request_and_sanitized_errors(self):
        content = json.dumps({'meanings': ['n. 缓存'], 'technical': ''})
        response = io.BytesIO(json.dumps({'choices': [{'message': {'content': content}}]}).encode())
        with patch('lookup_backend.credentials', return_value=('TEST_CREDENTIAL', 'deepseek-flash')), \
             patch('lookup_backend.urllib.request.urlopen', return_value=response) as request:
            self.assertEqual(translate('cache'), 'n. 缓存')
        payload = json.loads(request.call_args.args[0].data)
        self.assertEqual(payload['thinking'], {'type': 'disabled'})
        self.assertEqual(payload['response_format'], {'type': 'json_object'})
        self.assertEqual(payload['messages'][-1]['content'], 'cache')
        with patch('lookup_backend.credentials', return_value=('TEST_CREDENTIAL', 'deepseek-flash')), \
             patch('lookup_backend.urllib.request.urlopen', side_effect=urllib.error.HTTPError('url', 401, 'TEST_CREDENTIAL', None, None)):
            with self.assertRaises(LookupError) as e:translate('cache')
        self.assertIn('401', str(e.exception))
        self.assertNotIn('TEST_CREDENTIAL', str(e.exception))


    def test_credentials_read_dedicated_key_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            key = Path(tmp) / 'deepseek.key'
            with patch('lookup_backend.KEY_FILE', key):
                with self.assertRaises(LookupError):credentials()
                key.write_text('TEST_CREDENTIAL\n')
                self.assertEqual(credentials()[0], 'TEST_CREDENTIAL')


class ConcurrencyTests(unittest.TestCase):
    def test_old_results_and_audio_cannot_arrive_after_new_query(self):
        state = SimpleNamespace(generation=1, audio_ticket=1, closed=False, futures=[], drop_count=0,
                                update_diagnostics=lambda: None)
        started = threading.Event()
        release = threading.Event()
        got = []
        def old():
            started.set();release.wait(3);return 'old'
        with ThreadPoolExecutor(max_workers=2) as pool:
            LookupApp.schedule(state, pool, old, lambda v, e: got.append(v), ticket=1)
            self.assertTrue(started.wait(1))
            state.generation = 2;state.audio_ticket = 2
            LookupApp.schedule(state, pool, lambda: 'new', lambda v, e: got.append(v), ticket=2)
            release.set()
            deadline = time.monotonic() + 3
            context = GLib.MainContext.default()
            while time.monotonic() < deadline and (not got or state.drop_count < 1):
                while context.pending():context.iteration(False)
                time.sleep(.01)
        self.assertEqual(got, ['new'])
        self.assertEqual(state.drop_count, 1)


class VoiceTests(unittest.TestCase):
    def test_worker_exits_after_idle(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'a.wav'
            worker = Path(tmp) / 'worker.py'
            # 假 worker：每收到一行就写出文件并回复成功。
            worker.write_text("import json,sys,pathlib\nfor l in sys.stdin:\n"
                              "    pathlib.Path(json.loads(l)['path']).write_bytes(b'x')\n"
                              "    print(json.dumps({'ok': True}), flush=True)\n")
            voice = Voice();voice.IDLE = .2
            real_popen = subprocess.Popen
            fake_python = Path(tmp) / 'venv/bin/python'
            fake_python.parent.mkdir(parents=True);fake_python.touch()
            with patch('lookup_app.DATA', Path(tmp)), patch('lookup_app.subprocess.Popen',
                       side_effect=lambda cmd, **kw: real_popen([sys.executable, str(worker)], **kw)):
                self.assertEqual(voice.synthesize('hi', path, 'af_heart'), path)
                first = voice.process
                self.assertIsNone(first.poll())
                time.sleep(.5)
                self.assertIsNone(voice.process)
                self.assertIsNotNone(first.poll())
                voice.synthesize('again', path, 'af_heart')  # 退出后自动重启
                self.assertIsNotNone(voice.process)
            voice.stop()


class LoudnessTests(unittest.TestCase):
    def test_loud_and_quiet_sources_end_up_similar(self):
        with tempfile.TemporaryDirectory() as tmp:
            levels = []
            for volume in ('4', '0.3'):  # sine 源默认振幅 1/8，约 -9 与 -31 LUFS
                src, dst = Path(tmp) / f'{volume}.wav', Path(tmp) / f'{volume}-out.wav'
                subprocess.run(['ffmpeg', '-v', 'error', '-f', 'lavfi', '-i', f'sine=f=440:d=1.5',
                                '-af', f'volume={volume}', str(src)], check=True)
                level_audio(src, dst)
                levels.append(loudness(dst))
        self.assertTrue(all(abs(x + 19) < 1.5 for x in levels), levels)


class SelectionFallbackTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = LookupApp()
        cls.app.set_flags(Gio.ApplicationFlags.NON_UNIQUE)  # 不占用正在运行的小窗的 D-Bus 名称
        cls.app.register(None)
        cls.app.window.present = lambda: None  # 测试不弹窗
        cls.app.save_settings = lambda: None

    def setUp(self):
        self.app.last_selection = ''
        self.app.results.clear()
        self.reads = []
        patcher = patch.object(LookupApp, 'read_clipboard', lambda app, **kw: self.reads.append(kw))
        patcher.start();self.addCleanup(patcher.stop)
        self.api = patch('lookup_app.translate', return_value='译文').start();self.addCleanup(patch.stopall)
        patch('lookup_app.Dictionary.pronunciations', return_value=[]).start()

    def test_no_selection_reads_clipboard(self):
        self.app.lookup('', NO_SELECTION + ' · Kitty')
        self.assertEqual(self.reads, [{'fallback': True}])

    def test_new_selection_queries_and_repeat_checks_clipboard(self):
        self.app.lookup('ephemeral', '待确认 · 当前应用的桌面选区')
        self.assertEqual(self.reads, [])
        self.assertEqual(self.app.request_count and self.app.origin.get_text(), '当前应用的桌面选区')
        self.app.lookup('ephemeral', '待确认 · 当前应用的桌面选区')
        self.assertEqual(self.reads, [{'fallback': True, 'unless_seen': True}])

    def test_clipboard_fallback_never_loops_and_guards_secrets(self):
        self.app.lookup('', CLIPBOARD_FALLBACK)
        self.assertEqual(self.reads, [])
        self.assertIn('没有读取到文字', self.app.result.get_text())
        self.app.lookup('sk-abc123', CLIPBOARD_FALLBACK)
        self.assertIn('按 Enter 查询', self.app.result.get_text())
        self.app.lookup('The cache is warm.', CLIPBOARD_FALLBACK)
        self.assertEqual(self.app.origin.get_text(), '剪贴板（未选中文字）')


if __name__ == '__main__':
    unittest.main()
