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
├── home/
│   ├── .zshrc            # WSL2/Ubuntu 版 zshrc
│   ├── .p10k.zsh         # Powerlevel10k 配置（共用）
│   ├── .gitconfig        # Git 配置（共用）
│   ├── .tmux.conf        # Tmux 配置（共用）
│   └── .vimrc            # Vim 配置（共用）
├── config/
│   └── nvim/             # Neovim 配置（共用）
└── arch/
    ├── setup.sh          # Arch Linux 安装脚本
    ├── packages.txt      # pacman 包列表
    ├── packages-aur.txt  # AUR 包列表
    └── home/
        └── .zshrc        # Arch Linux 版 zshrc
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
- **CLI 工具**：bat、eza、fzf、lsd、ripgrep、zoxide、lazygit
- **编辑器**：Neovim（含完整插件配置）、Vim
- **开发环境**：Java 21（`jdk21-openjdk`）
- **Git**：git-delta 并排 diff 视图
- **终端复用**：Tmux

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
