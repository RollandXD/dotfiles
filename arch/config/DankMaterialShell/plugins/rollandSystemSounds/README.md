# 统一提示音

打开 DMS 控制中心的「提示音」卡片，展开后：顶部是当前统一音量与静音/试听，下方滑块调音量；来源按「系统 / 工具 / AI 助手」分组，每行可**单独开关**、试听；点一行（或右侧调节图标）展开**响度滑块**（±6 dB，0.5 dB 一格，拖动实时生效、松手自动试听，旁边有复位）。微调过的来源行右侧会显示偏移读数。音量使用标准 `sink-input-by-media-role:event` 恢复键，0–100%；音乐/视频继续使用自己的音量。pavucontrol 的「系统声音」控件操作同一恢复键；插件同时同步现有事件流；单个应用的临时播放流滑块不作为主控，改动会被统一值重新覆盖。

## 已接入

- DMS：音量反馈、登录、普通/紧急通知、插拔电源。
- 截图：保留原快捷键 SIGUSR1 上膛与 15 秒超时，改监听 `~/Pictures/Screenshots/Screenshot from ...png` 的文件完成事件。取消、超时与普通文件复制不响。更改 niri 截图路径后，同步调整脚本的 `SCREENSHOT_DIR`。
- Kitty BEL：`command_on_bell system-sounds play bell`，关闭内置音频铃声，防止重复；tmux 现有 bell 触发策略保留。
- `timer`：从系统包提供的脚本建立用户副本，只改提示音播放与作用域内清理；原 `/usr/lib/shorin-contrib/timer` 保留。更新 shorin-contrib 后需人工比较本地副本。
- Claude Code：chime mod（`~/.claude/mods/chime`）的三个提示音登记为来源 `claude-done` / `claude-ask` / `claude-nudge`，经 `system-sounds play` 播放。终端在前台时用 `--quiet 7` 轻响（不再靠 `pw-play --volume`，那会被 event 恢复键覆盖）；弹通知时带 `suppress-sound` 提示，避免 DMS 再叮一声。`system-sounds` 不可用时 chime 才退回 `pw-play`。
- Codex：`~/.local/bin/codex-hook-notify.sh` 在 Stop / PermissionRequest 时播放 `codex-done` / `codex-ask`（马林巴音色、不同音型：三音上行 = 完成，二音下行 = 确认；源文件与合成命令见 `~/.config/system-sounds/{sounds,tools}`），终端前台时同样 `--quiet 7`，通知带 `suppress-sound`；SubagentStop 只弹通知不响。
- 其他 `notify-send`：桌面通知进入 DMS 通知音；终端 BEL 进入 Kitty。

浏览器网页、游戏等自行以 Music 播放的提示音无法靠应用名安全区分；不能把整个 Firefox 路由为提示音，否则视频也会受影响。此类来源用 `system-sounds doctor` 识别（它会扫描常用脚本目录里绕过 system-sounds 的 `pw-play`/`paplay`/`aplay` 调用），再按应用支持接入。已知故意直连的行尾加 `# system-sounds: allow` 即可豁免。标准 `event`/`Notification` 流共用系统事件音量，逐来源响度校准只覆盖已登记文件。

## 使用命令

```sh
system-sounds status               # 音量 + 各来源状态（人类可读）
system-sounds doctor               # 依赖/恢复键/插件后台/绕过扫描，有失败项时退出码为 1
system-sounds volume set 50        # 也可 up [步长] / down [步长]；up 会顺带取消静音
system-sounds mute toggle
system-sounds play screenshot
system-sounds play claude-done --quiet 7   # 临时衰减 7 dB，变体缓存，不影响来源别名
system-sounds disable bell         # 关闭某来源（enable 恢复）；play --force 仍可试听
system-sounds trim screenshot -1
system-sounds audit                # JSON：来源清单与当前播放流（面板使用）
system-sounds calibrate
dms ipc call system-sounds open eDP-1
```

新声音在 `~/.config/system-sounds/sources.json` 注册：

```json
{"my-alert":{"file":"~/sounds/alert.wav","event":"completion","label":"我的提示音","group":"ai","kind":"script","offset_db":2}}
```

字段：`level` 设为 `"momentary"` 时按 K 加权 400 ms 瞬时最大响度对齐（默认目标 −28 LUFS，可用 `target_m` 覆盖）——适合“一声衰减的提示音”，积分 LUFS 会让这类声音偏响；缺省沿用积分 LUFS / 短音 RMS（DMS 自带音效仍是这套）。`label` 面板显示名；`group` 取 `system` / `tools` / `ai`（缺省归「其他」）；`offset_db` 来源自带的基准响度偏移（想让它整体比别的响/轻时用，与面板上的用户微调相互独立）。

运行 `system-sounds calibrate`，将原播放命令改为 `system-sounds play my-alert`。来源标识使用字母、数字、连字符和下划线。`trims.json` 保留微调、`disabled.json` 保存被关闭的来源；缓存可以重建，原文件不修改。DMS 内置播放器的「关闭」通过各自 AudioOutput 静音实现，脚本类来源由 `play` 自行跳过。

## 标定与边界

保留音色/节奏，做恒定增益；较长音效目标 −24 LUFS，极短音效采用活动段 RMS −26 dBFS。最大提升 +6 dB，真实峰值不超过约 −3 dBTP；峰值/增益受限时不会强行达到目标，因此不同音效仍可能有听感差异，使用 ±1 dB 微调。输出统一为 48 kHz、立体声 PCM，避免当前 WirePlumber 把 mono 恢复数组套到 stereo 时右声道归零。

插件同步 Qt 线性幅度与 Pulse 百分比，启动未获得后端状态前暂缓 DMS 通知声音。DMS 原有 DND、声音开关和系统输出静音仍生效；截图、BEL、闹钟沿用各自原有触发条件并服从统一静音。当前保持媒体播放时可响。

**改 QML 后**：`dms ipc call plugins reload rollandSystemSounds` 只会刷新后台 daemon，面板组件被 DMS 缓存，需 `systemctl --user restart dms.service`（先确认未锁屏）才生效；改 `system-sounds` 脚本或 sources.json 无需重启。

依赖：DMS >=1.6.2、可用的 QtMultimedia、Python、libpulse、pactl/paplay、FFmpeg/ffprobe、inotify-tools。插件通过公开 QML 属性替换播放器音源；DMS 升级后需重新验证这些属性及插件接口。

## 当前部署与恢复

源码在 `~/dotfiles/arch/local/bin/system-sounds`、`~/dotfiles/arch/config/DankMaterialShell/plugins/rollandSystemSounds/`。来源配置在 `~/dotfiles/arch/config/system-sounds/`，通过 `~/.config/system-sounds` 链接持久化。对应用户入口均为符号链接；DMS 进程音频通过 `dms.service.d/60-system-sounds.conf` 标为通知。

恢复点有两个：重构前快照 `~/.local/state/system-sounds-backups/20261007-refactor/`（见其中 `RESTORE.md`，手动拷回即可）；最初交付前 `20261007-initial/`（下面的 `restore.py`）。重构改动了其校验的文件，`restore.py --check` 现在会因“后续修改”而拒绝执行，这是预期行为。

```sh
python ~/.local/state/system-sounds-backups/20261007-initial/restore.py --check
python ~/.local/state/system-sounds-backups/20261007-initial/restore.py --apply
```

恢复先完整核对本次文件与新增设置；存在后续修改时拒绝执行，不会覆盖其他设置。仅回退本次改动，缓存保留。回退前保存用户当前微调；完整恢复未在真实桌面执行，以免撤销交付。
