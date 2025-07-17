zmodload zsh/zprof

source "/home/tenzin/.zsh/aliases.zsh"
source "/home/tenzin/.zsh/fns.zsh"

alias ssr="ssh rock@192.168.68.72"

path=(
	$PATH
	~/.cargo/bin
	~/.npm-packages
	~/scripts
	/home/tenzin/.spicetify
	/home/tenzin/.local/bin
	/usr/bin
)

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=""

plugins=(
	zsh-autosuggestions
)

export ROS_DOMAIN_ID=123
export ROS_DISTRO=jazzy
export PATH="${(j/:/)path}"
export EDITOR="nvim"

setopt NO_AUTO_CD 

if [[ $- == *i* ]]; then
  source $ZSH/oh-my-zsh.sh
  . "$HOME/.cargo/env"
	eval "$(zoxide init zsh --cmd cd)"
	eval "$(fzf --zsh)"

  bindkey '' autosuggest-accept

  zle -N set-nv
  bindkey '' set-nv

  zle -N set-cd
  bindkey '' set-cd

  zle -N run-ls
  bindkey '' run-ls

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ?
# . "$HOME/.local/share/../bin/env"

zprof
