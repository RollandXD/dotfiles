#!/usr/bin/env bash
# Arch Linux dotfiles 安装脚本
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> [1/7] 安装 pacman 包..."
sudo pacman -Syu --needed - < "$DOTFILES_DIR/arch/packages.txt"

echo "==> [2/7] 安装 AUR 包（需要 yay 或 paru）..."
if command -v yay &>/dev/null; then
  grep -v '^#' "$DOTFILES_DIR/arch/packages-aur.txt" | grep -v '^$' | yay -S --needed -
elif command -v paru &>/dev/null; then
  grep -v '^#' "$DOTFILES_DIR/arch/packages-aur.txt" | grep -v '^$' | paru -S --needed -
else
  echo "  ⚠ 未找到 yay/paru，跳过 AUR 包安装"
  echo "    手动安装 AUR 包请参考 arch/packages-aur.txt"
fi

echo "==> [3/7] 安装 Oh My Zsh（若未安装）..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "==> [4/7] 安装 Zsh 插件..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ] && \
  git clone --depth=1 https://github.com/romkatv/powerlevel10k "$ZSH_CUSTOM/themes/powerlevel10k"

echo "==> [5/7] 链接配置文件..."
# Arch 专用 zshrc
ln -sf "$DOTFILES_DIR/arch/home/.zshrc"  "$HOME/.zshrc"

# 共用文件（直接引用仓库根目录下的版本）
ln -sf "$DOTFILES_DIR/home/.p10k.zsh"   "$HOME/.p10k.zsh"
ln -sf "$DOTFILES_DIR/home/.gitconfig"  "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/home/.tmux.conf"  "$HOME/.tmux.conf"
ln -sf "$DOTFILES_DIR/home/.vimrc"      "$HOME/.vimrc"

# Neovim 配置
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES_DIR/config/nvim"      "$HOME/.config/nvim"

# 桌面环境（niri 滚动平铺 + DMS shell + kitty 终端）
# 用 -sfn：当目标已是链接目录时，替换链接本身而非穿透写入
ln -sfn "$DOTFILES_DIR/arch/config/niri"   "$HOME/.config/niri"
ln -sfn "$DOTFILES_DIR/arch/config/kitty"  "$HOME/.config/kitty"

# DMS：保留原目录（DMS 启动时会写 .firstlaunch 等运行时标记），只链具体配置文件
mkdir -p "$HOME/.config/DankMaterialShell"
ln -sf "$DOTFILES_DIR/arch/config/DankMaterialShell/settings.json" \
       "$HOME/.config/DankMaterialShell/settings.json"
ln -sf "$DOTFILES_DIR/arch/config/DankMaterialShell/firefox.css" \
       "$HOME/.config/DankMaterialShell/firefox.css"

# DMS 磁盘组件：状态栏 pill 点击打开 /、/home 和 /mnt/wingame 详情
mkdir -p "$HOME/.config/DankMaterialShell/plugins"
ln -sfn "$DOTFILES_DIR/arch/config/DankMaterialShell/plugins/storageMonitor" \
        "$HOME/.config/DankMaterialShell/plugins/storageMonitor"
ln -sf "$DOTFILES_DIR/arch/config/DankMaterialShell/plugin_settings.json" \
       "$HOME/.config/DankMaterialShell/plugin_settings.json"

# 截图 OCR：脚本纳入 dotfiles，模型放 XDG 数据目录，不把 40+ MiB 二进制提交进仓库
mkdir -p "$HOME/.local/bin"
ln -sf "$DOTFILES_DIR/arch/local/bin/dank-ocr" \
       "$HOME/.local/bin/dank-ocr"
ln -sf "$DOTFILES_DIR/arch/local/bin/install-dank-ocr-models" \
       "$HOME/.local/bin/install-dank-ocr-models"
ln -sf "$DOTFILES_DIR/arch/local/bin/dank-shutdown" \
       "$HOME/.local/bin/dank-shutdown"

# 磁盘空间监控：状态栏由 DMS 展示，user timer 负责跨阈值通知
mkdir -p "$HOME/.config/systemd/user"
ln -sf "$DOTFILES_DIR/arch/local/bin/disk-space-guard" \
       "$HOME/.local/bin/disk-space-guard"
ln -sf "$DOTFILES_DIR/arch/local/share/systemd/user/disk-space-guard.service" \
       "$HOME/.config/systemd/user/disk-space-guard.service"
ln -sf "$DOTFILES_DIR/arch/local/share/systemd/user/disk-space-guard.timer" \
       "$HOME/.config/systemd/user/disk-space-guard.timer"
systemctl --user daemon-reload
systemctl --user enable disk-space-guard.timer

echo "==> [6/7] 安装截图 OCR 高精度模型..."
"$HOME/.local/bin/install-dank-ocr-models"

echo "==> [7/7] 设置默认 Shell 为 zsh..."
chsh -s "$(which zsh)"

echo ""
echo "✓ 安装完成！请重启终端。"
echo "  若 .p10k.zsh 已存在，主题将自动加载。"
echo "  首次配置主题可运行：p10k configure"
