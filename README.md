# dotfiles — RollandXD

Personal dotfiles supporting two environments:

| Environment | Install script |
|---|---|
| WSL2 / Ubuntu | `bash setup.sh` |
| Arch Linux (KDE6) | `bash arch/setup.sh` |

---

## Repository structure

```
dotfiles/
├── setup.sh              # WSL2/Ubuntu 安装脚本
├── home/                 # WSL2/Ubuntu 专属 dotfiles
│   ├── .zshrc
│   ├── .p10k.zsh         # Powerlevel10k（也被 Arch 共用）
│   ├── .gitconfig        # Git + delta Catppuccin 配色（也被 Arch 共用）
│   ├── .tmux.conf        # Tmux（也被 Arch 共用）
│   └── .vimrc            # Vim（也被 Arch 共用）
├── config/
│   └── nvim/             # Neovim 配置（跨平台共用）
├── common/               # 跨系统共享
│   ├── .gitconfig        # 身份信息 + http 设置
│   └── .ideavimrc        # IdeaVim
├── arch/                 # Arch Linux (niri + DMS) 专属
│   ├── setup.sh
│   ├── packages.txt      # pacman 包列表
│   ├── packages-aur.txt  # AUR 包列表
│   ├── home/
│   │   └── .zshrc        # Arch 版 zshrc
│   ├── local/bin/
│   │   ├── dank-ocr      # Wayland 框选 OCR
│   │   ├── install-dank-ocr-models
│   │   ├── disk-space-guard
│   │   └── dank-shutdown
│   └── config/
│       ├── niri/         # 滚动平铺 Wayland 合成器（含 dms/、shorin-niri/ 子配置）
│       ├── kitty/        # 终端（Catppuccin Frappe）
│       └── DankMaterialShell/
│           ├── settings.json   # DMS 用户设置
│           └── firefox.css     # DMS Firefox 样式注入
└── windows/              # Windows 专属
    └── vscode/           # VSCode keybindings + settings
```

---

## Arch Linux (KDE6) 安装

### 前置条件

- 已安装 Arch Linux，网络可用
- 可选：提前安装 `yay` 或 `paru`（用于 AUR 包）

### 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/RollandXD/dotfiles ~/dotfiles

# 2. 运行安装脚本
bash ~/dotfiles/arch/setup.sh

# 3. 重启终端，若需要配置 p10k 主题：
p10k configure
```

### 安装内容

- **Shell**：Zsh + Oh My Zsh + Powerlevel10k
- **Zsh 插件**：zsh-autosuggestions、zsh-syntax-highlighting
- **CLI 工具**：bat、eza、fzf、fuzzel、lsd、ripgrep、zoxide、lazygit
- **编辑器**：Neovim（含完整插件配置）、Vim
- **开发环境**：Java 21（`jdk21-openjdk`）
- **Git**：git-delta 并排 diff 视图
- **终端复用**：Tmux
- **桌面环境**：niri（滚动平铺 Wayland 合成器）+ DankMaterialShell（QuickShell 状态栏）+ kitty 终端
- **截图 OCR**：Tesseract `tessdata_best` 中英模型、低置信度自动放大重试、结果写入剪贴板

> 注：niri / DMS / kitty 配置只能链接，不会自动安装这些软件。请先按各自项目说明装好运行时（`niri`、`quickshell` 等），再跑 `arch/setup.sh`。

### 截图 OCR

- `Super + Alt + O`：中英混排框选取字
- `Super + Alt + Shift + O`：纯英文、代码或报错信息
- `dank-ocr --sparse`：识别位置分散的界面文字

高精度模型固定到安装脚本记录的官方 `tessdata_best` 提交，安装在
`~/.local/share/tessdata-best/`，不会覆盖 pacman 管理的系统模型。需要单独
修复或更新模型时运行 `install-dank-ocr-models`。

### 磁盘空间监控

- DMS 状态栏显示 `/`、`/home` 和 `/mnt/wingame` 的使用率，点击可查看详情。
- `disk-space-guard.timer` 每 5 分钟检查一次空间和 Snapper 清理 timer，并在跨越阈值时通知。
- 可用 `disk-space-guard --test warning` 等参数发送一次测试通知；脚本不会删除文件。
- `arch/setup.sh` 会链接 unit、执行 user manager reload 并 enable timer，但不主动 `--now`；需要用
  `systemctl --user is-enabled disk-space-guard.timer` 回读启用状态。

### 定时关机

- `Super + Ctrl + P` 打开 `fuzzel` 关机菜单。
- `dank-shutdown in 90m` 或 `dank-shutdown at 23:30` 创建计划，`status` 查看，`cancel` 取消。
- `DANK_SHUTDOWN_DRY_RUN=1 dank-shutdown now` 只打印动作，不执行真实关机。

### 验证

```bash
zsh --version && echo $SHELL          # → /usr/bin/zsh
nvim                                  # Lazy.nvim 自动安装插件
bat README.md                         # 语法高亮
lsd -l                                # 图标显示
git diff                              # delta 并排格式
env | grep -i proxy                   # 应为空（无 WSL 代理残留）
```

---

## WSL2 / Ubuntu 安装

```bash
git clone https://github.com/RollandXD/dotfiles ~/dotfiles
bash ~/dotfiles/setup.sh
```

WSL 版包含代理自动配置（`proxyon`/`proxyoff`）和 IntelliJ IDEA Windows 启动函数（`idea()`）。

---

## 日常更新

由于配置文件全部以软链接方式纳管，编辑仓库即生效，跨机器同步也只需 git：

```bash
# 在仓库目录里改完后
cd ~/dotfiles && git add . && git commit -m "..." && git push

# 在另一台机器拉取最新配置
cd ~/dotfiles && git pull
```

不需要重跑 `setup.sh`，除非新增了链接目标。

---

## 主要差异（WSL vs Arch）

| 项目 | WSL2/Ubuntu | Arch Linux |
|---|---|---|
| fzf 安装方式 | `~/.fzf`（git clone） | pacman |
| fzf 脚本路径 | `~/.fzf/shell/` | `/usr/share/fzf/` |
| bat 命令名 | `batcat` | `bat` |
| JAVA_HOME | `.../java-21-openjdk-amd64` | `.../java-21-openjdk` |
| WSL 代理配置 | 包含 | 不包含 |
| `idea()` 函数 | 包含 | 不包含 |
| Node.js (nvm) | 包含 | 不包含 |
