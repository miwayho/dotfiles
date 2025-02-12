export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export RANGER_LOAD_DEFAULT_RC=false
export EDITOR=nvim
export WORKON_HOME=$HOME/.virtualenvs
export PYENV_VIRTUALENVWRAPPER_PREFER_PYVENV="true"

ZSH_THEME="minimal"

plugins=(git sudo zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh
source /usr/local/bin/virtualenvwrapper.sh

alias f="ranger"

eval "$(pyenv init -)"
