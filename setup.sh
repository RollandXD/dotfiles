#!/usr/bin/env bash
# ============================================================
# Dotfiles 一键安装脚本
# 用法：bash setup.sh
# ============================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📂 Dotfiles 目录: $DOTFILES_DIR"

# ---------- 颜色输出 ----------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
section() { echo -e "\n${YELLOW}===== $1 =====${NC}"; }

# ---------- 创建符号链接的辅助函数 ----------
link_file() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    mkdir -p "$dst_dir"

    if [ -L "$dst" ]; then
        rm "$dst"
        info "已更新链接: $dst"
    elif [ -e "$dst" ]; then
        mv "$dst" "${dst}.bak"
        warn "已备份原文件: ${dst}.bak"
    fi

    ln -s "$src" "$dst"
    info "链接创建: $dst -> $src"
}

# ============================================================
# 1. 安装 apt 包
# ============================================================
section "安装 apt 包"
if [ -f "$DOTFILES_DIR/packages.txt" ]; then
    # 过滤掉系统基础包，只安装用户常用工具
    USER_PACKAGES=(
        bat curl eza fzf git git-delta jq lsd ripgrep tmux tree unzip zoxide zsh
    )
    echo "准备安装: ${USER_PACKAGES[*]}"
    sudo apt-get update -q
    sudo apt-get install -y "${USER_PACKAGES[@]}" || warn "部分包安装失败，继续..."
    info "apt 包安装完成"
else
    warn "未找到 packages.txt，跳过 apt 安装"
fi

# ============================================================
# 2. 安装 Oh My Zsh
# ============================================================
section "安装 Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "正在安装 Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    info "Oh My Zsh 已存在，跳过"
fi

# ============================================================
# 3. 安装 Zsh 插件和主题
# ============================================================
section "安装 Zsh 插件"

OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Powerlevel10k 主题
if [ ! -d "$OMZ_CUSTOM/themes/powerlevel10k" ]; then
    info "安装 Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$OMZ_CUSTOM/themes/powerlevel10k"
else
    info "Powerlevel10k 已存在"
fi

# zsh-autosuggestions 插件
if [ ! -d "$OMZ_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$OMZ_CUSTOM/plugins/zsh-autosuggestions"
else
    info "zsh-autosuggestions 已存在"
fi

# zsh-syntax-highlighting 插件
if [ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
else
    info "zsh-syntax-highlighting 已存在"
fi

# ============================================================
# 4. 安装 fzf
# ============================================================
section "安装 fzf"
if [ ! -d "$HOME/.fzf" ]; then
    info "安装 fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --key-bindings --completion --no-update-rc
else
    info "fzf 已存在"
fi

# ============================================================
# 5. 安装 vim-plug（Vim 插件管理器）
# ============================================================
section "安装 vim-plug"
VIM_PLUG="$HOME/.vim/autoload/plug.vim"
if [ ! -f "$VIM_PLUG" ]; then
    info "安装 vim-plug..."
    curl -fLo "$VIM_PLUG" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
    info "vim-plug 已存在"
fi

# ============================================================
# 6. 创建配置文件符号链接
# ============================================================
section "创建符号链接"

# home 目录下的 dotfiles
for file in "$DOTFILES_DIR"/home/.*; do
    filename="$(basename "$file")"
    # 跳过 . 和 ..
    [[ "$filename" == "." || "$filename" == ".." ]] && continue
    # 跳过 codex 工具留下的备份文件
    [[ "$filename" == *.bak.codex-* ]] && continue
    link_file "$file" "$HOME/$filename"
done

# ~/.config 下的配置
link_file "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# ============================================================
# 7. 修复 fzf.zsh 中的硬编码路径
# ============================================================
section "修复 fzf.zsh 路径"
FZF_ZSH="$HOME/.fzf.zsh"
if [ -L "$FZF_ZSH" ]; then
    # 临时替换为动态路径
    FZF_ZSH_CONTENT='# Setup fzf (动态路径，由 setup.sh 生成)
if [[ ! "$PATH" == *"$HOME/.fzf/bin"* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi
source <(fzf --zsh)'
    echo "$FZF_ZSH_CONTENT" > "$HOME/.fzf.zsh.local"
    info "fzf 路径已修复，使用 ~/.fzf.zsh.local"
fi

# ============================================================
# 8. 设置 zsh 为默认 shell
# ============================================================
section "设置默认 Shell"
if [ "$SHELL" != "$(which zsh)" ]; then
    info "将 zsh 设为默认 shell..."
    chsh -s "$(which zsh)"
else
    info "zsh 已是默认 shell"
fi

# ============================================================
echo ""
echo -e "${GREEN}🎉 安装完成！${NC}"
echo "请重新打开终端或运行: exec zsh"
echo ""
echo "注意事项："
echo "  1. WSL 代理配置需要根据新机器的端口调整（当前: 7897）"
echo "  2. Java 路径可能不同，请检查 ~/.zshrc 中 JAVA_HOME 设置"
echo "  3. SSH 密钥需要手动配置"
