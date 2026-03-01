# Rolland's Dotfiles

我的 WSL2/Ubuntu 开发环境配置，一键迁移到新机器。

## 包含内容

| 文件 | 说明 |
|------|------|
| `home/.zshrc` | Zsh 配置（Oh My Zsh + 插件 + 别名 + 代理配置） |
| `home/.zprofile` | Zsh 登录配置（pipx 路径） |
| `home/.p10k.zsh` | Powerlevel10k 主题配置 |
| `home/.gitconfig` | Git 配置（delta diff、用户信息） |
| `home/.tmux.conf` | Tmux 配置（Vim 风格按键、鼠标支持） |
| `home/.vimrc` | Vim 配置（插件、快捷键、界面） |
| `home/.fzf.zsh` | fzf 快捷键集成 |
| `config/nvim/` | Neovim 完整配置（Lazy.nvim） |
| `packages.txt` | 手动安装的 apt 包列表 |

## 快速安装

```bash
# 1. 克隆仓库
git clone https://github.com/你的用户名/dotfiles.git ~/dotfiles

# 2. 运行安装脚本
cd ~/dotfiles
chmod +x setup.sh
bash setup.sh

# 3. 重启终端
exec zsh
```

## 主要工具栈

- **Shell**: Zsh + Oh My Zsh + Powerlevel10k
- **编辑器**: Neovim（主力）+ Vim（备用）
- **终端复用**: Tmux
- **文件工具**: eza (ls)、bat (cat)、lsd、tree
- **搜索**: fzf、ripgrep、zoxide
- **Git 增强**: git-delta（diff 美化）、lazygit
- **运行时**: Java 21、Node.js（nvm）、Python 3、Bun

## 新机器注意事项

1. **WSL 代理**：修改 `~/.zshrc` 中代理端口（当前 `7897`）
2. **Java 路径**：安装后确认 `JAVA_HOME` 路径是否正确
3. **SSH 密钥**：手动配置 `~/.ssh/`（出于安全不纳入仓库）
4. **VPS 别名**：修改 `myvps` alias 中的 IP 地址
