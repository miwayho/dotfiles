export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export RANGER_LOAD_DEFAULT_RC=false
export EDITOR=nvim

ZSH_THEME="minimal"

plugins=(git sudo zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

alias ssh="wezterm ssh"
alias f="ranger"