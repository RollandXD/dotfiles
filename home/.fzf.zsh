# Setup fzf
# ---------
if [[ ! "$PATH" == */home/rolland/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/rolland/.fzf/bin"
fi

source <(fzf --zsh)
