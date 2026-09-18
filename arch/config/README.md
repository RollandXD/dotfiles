# Arch 配置边界

## DMS 与 Niri

- `DankMaterialShell/settings.json` 保存 DMS 的持久化偏好；其中 `matugenTargetMonitor` 当前绑定本机 `eDP-1`，换机或显示器命名变化时需要调整。
- `DankMaterialShell/plugins/storageMonitor/StorageMonitor.qml` 当前监控 `/`、`/home` 和 `/mnt/wingame`；`/mnt/wingame` 是本机专属挂载点。
- `niri/dms/*.kdl` 主要由 DMS 生成。`dms/binds.kdl` 保留 DMS 基础快捷键与本机 DMS 映射，个人快捷键统一放在 `niri/shorin-niri/binds.kdl`。
- `niri/dms/outputs.kdl`、光标主题和 `config.kdl` 中的桌面环境变量属于本机运行环境；恢复到其他机器前应先核对显示器、输入法和启动项。

不要使用 `dms setup --force` 覆盖现有配置；需要更新时优先让 DMS 重生成其管理文件，再检查本目录中的个人 include 和本机专属值。
