# 英文随查

选中英文后弹出 GTK4 浮动小窗：单词给中文词义、剑桥/朗文美音录音和音标，句子给译文，按需用 Kokoro 合成朗读。
2026-10-09 在 playground 试验，2026-10-18 迁入 dotfiles；试验期记录归档在 `~/Code/playground/archive/english-lookup-trial/`。

## 使用

| 场景 | 操作 |
|---|---|
| Kitty 鼠标选区 | **Super+A**，读当前窗口的真实选区；没有选区时改读剪贴板 |
| PDF、浏览器等其他应用 | **Super+A**，读桌面 PRIMARY；普通英文直接查，与上次相同或像密钥/代码的先确认，按 **Enter** 发送 |
| 已复制的文字（Codex/TUI 内部选区、OCR 结果） | **Super+A** 打开后点“粘贴并查询” |
| nvim | 普通模式或 Visual 模式按 **空格 t e**，不改寄存器 |
| 小窗已聚焦时 | 再按 **Super+A** 关闭 |

小窗内：Esc 关闭、Enter 查询、Shift+Enter 换行、Ctrl+R 重播。关闭后进程保留，隐藏并闲置十分钟后退出。
`english-lookup open|quit|status` 分别打开空白小窗、退出后台实例、输出诊断摘要。

## 文件

| 内容 | 位置 |
|---|---|
| 入口 / 模型安装脚本 | `arch/local/bin/english-lookup`、`arch/local/bin/install-english-lookup-models`（setup.sh 链到 `~/.local/bin`） |
| 代码与测试 | 本目录：`lookup_app.py` 界面与取选区，`lookup_backend.py` 翻译与词典，`voice_worker.py` Kokoro 合成 |
| Kitty 选区授权 | `arch/config/kitty/kitty_selection_auth.py`，只放行 socket 上对当前窗口当前选区的 `get-text` |
| niri 绑定 | `arch/config/niri/english-lookup.kdl` |
| 合成环境与模型（约 550 MiB） | `~/.local/share/english-lookup/{venv,models}`，跑 `install-english-lookup-models` 安装或修复 |
| 设置与词典录音缓存 | `~/.local/state/english-lookup/` |
| DeepSeek key | `~/.config/english-lookup/deepseek.key`（权限 600，专用 key，与 voxtype 分开计量） |

模型默认 `deepseek-flash`，可用环境变量 `ENGLISH_LOOKUP_MODEL` 覆盖。

## 依赖与隐私

运行时依赖 `/usr/bin/python` 的 `python-gobject`、`gtk4`、`gst-plugins-base/good`、`ffmpeg`、`wl-clipboard`，安装脚本另需 `uv`。
没装合成环境时仍能查词义、播放词典录音，只是句子不能朗读。

不记录查询历史；翻译只在内存缓存。词典站点会收到所查单词，DeepSeek 会收到待解释的文本。
Kitty 的 `listen_on` socket 位于 `$XDG_RUNTIME_DIR`，同一用户下的进程都能读到当前选区，但读不到其他内容。监听只对新开的 Kitty 生效。

## 测试

```sh
PYTHONDONTWRITEBYTECODE=1 python -m unittest discover -s ~/dotfiles/arch/local/share/english-lookup/tests
```
