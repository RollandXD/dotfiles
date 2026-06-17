# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git fzf-tab zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- 历史记录优化 ---
HISTSIZE=50000                  # 内存中保留的历史条数
SAVEHIST=50000                  # 写入历史文件的条数
setopt HIST_IGNORE_ALL_DUPS     # 同样的命令只留最近一条
setopt HIST_SAVE_NO_DUPS        # 写文件时去重
setopt HIST_REDUCE_BLANKS       # 去掉命令里多余空格
setopt HIST_IGNORE_SPACE        # 以空格开头的命令不记录（临时敏感命令）
setopt SHARE_HISTORY            # 多终端实时共享历史
setopt HIST_VERIFY              # Ctrl-R 选中后先回显，回车再执行

# --- 别名 ---
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lt='lsd --tree --depth 2'
alias ltt='lsd --tree'

# zoxide
eval "$(zoxide init zsh)"

# bat (installed as 'bat' via pacman on Arch)
alias cat='bat'
export BAT_THEME="Catppuccin Mocha"   # 与 kitty 配色统一（bat 已内置该主题）

# fzf (installed via pacman) — 集成脚本由 fzf 二进制生成，随版本自动同步
eval "$(fzf --zsh)"

# fzf 外观（全局，不放 preview，避免污染 Ctrl-R / Alt-C）
export FZF_DEFAULT_OPTS="--tmux center --height 40% --layout=reverse --border \
  --color=spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=border:#6c7086,label:#cdd6f4"

# fzf 全局搜索（从 $HOME 开始，不限于当前目录）
# Ctrl+T 搜索文件，Alt+C 搜索目录
export FZF_CTRL_T_COMMAND="fd --type f --hidden --follow --exclude .git . $HOME"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git . $HOME"

# 只有选「文件」时才用 bat 预览（避免 Ctrl-R 把历史命令当文件喂给 bat）
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
# 选「目录」时用 eza 预览目录树
export FZF_ALT_C_OPTS="--preview 'lsd --tree --depth 2 --color=always {} | head -200'"

# fzf-tab：把 Tab 补全菜单换成 fzf 界面 + 预览
zstyle ':fzf-tab:*' switch-group '<' '>'                       # 用 < > 切换补全分组
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --tree --depth 2 --color=always $realpath'

# fzf-git：Ctrl-G 再按字母选 git 对象（Ctrl-B 分支 / Ctrl-H 提交 / Ctrl-T 文件 / Ctrl-R 远端 …）
[ -f ~/.local/share/fzf-git.sh ] && source ~/.local/share/fzf-git.sh

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# 我的vps远程地址
alias myvps="ssh root@38.47.118.244"

# Java 21 (Arch package: jdk21-openjdk)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export PATH=$JAVA_HOME/bin:$PATH
export PATH="$HOME/.npm-global/bin:$PATH"

# 将 nvim 设置为默认编辑器（包括 sudo 编辑）
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim

# bun completions
[ -s "/home/rolland/.bun/_bun" ] && source "/home/rolland/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# conda 懒加载：首次输入 conda 命令时才初始化（加快 shell 启动）
conda() {
    unfunction conda
    source /opt/miniconda3/etc/profile.d/conda.sh
    conda "$@"
}

# atuin：增强 shell 历史（装了才启用；接管 Ctrl-R，保留 ↑ 为原行为）
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

# yazi：退出后自动 cd 到浏览的目录（按 Q 退出则不改变目录）
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}
