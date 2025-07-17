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
	~/.scripts
	/usr/bin
)

pokego -r 1 --no-title | fastfetch --file-raw -

plugins=(
	zsh-autosuggestions
)

. "$HOME/.cargo/env"

export ROS_DOMAIN_ID=10
export PATH="${(j/:/)path}"
export EDITOR="nv"

eval "$(zoxide init zsh --cmd cd)"
# eval "$(fzf --zsh)"

bindkey '' autosuggest-accept

zle -N set-nv
bindkey '' set-nv

zle -N set-cd
bindkey '' set-cd

zle -N run-ls
bindkey '' run-ls

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
