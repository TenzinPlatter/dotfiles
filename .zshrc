source "/home/tenzin/.zsh/aliases.zsh"
source "/home/tenzin/.zsh/fns.zsh"
# source "/home/tenzin/.zsh/node_bloat.zsh"
[[ -f "/home/tenzin/.zsh/env.zsh" ]] && source "/home/tenzin/.zsh/env.zsh"

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
	you-should-use
)

export ROS_DOMAIN_ID=123
export ROS_DISTRO=jazzy
export ROS_OVERLAY=/opt/ros/jazzy
export ROS_VERSION=2
export PATH="${(j/:/)path}"
export EDITOR="nvim"

setopt NO_AUTO_CD 

if [[ $- == *i* ]]; then
  pokego -r 1 --no-title | fastfetch --file-raw -

  source $ZSH/oh-my-zsh.sh
  . "$HOME/.cargo/env"
	eval "$(zoxide init zsh --cmd cd)"

  bindkey '^ ' autosuggest-accept

  zle -N set-nv
  bindkey '' set-nv

  zle -N set-cd
  bindkey '' set-cd

  zle -N run-ls
  bindkey '' run-ls

  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PNPM_HOME="/home/tenzin/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
