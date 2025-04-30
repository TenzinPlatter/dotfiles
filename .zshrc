source "/home/tenzin/.zsh/aliases.zsh"
source "/home/tenzin/.zsh/fns.zsh"

path=(
	$PATH
	~/.cargo/bin
	~/.npm-packages
	~/.scripts
	/home/tenzin/.spicetify
	/home/tenzin/.local/bin
	~/.scripts
	/usr/bin
)

. "$HOME/.cargo/env"

export PATH="${(j/:/)path}"
export EDITOR="helix"

export LD_LIBRARY_PATH="/home/tenzin/coding/c/comp2017_p1/target/libraries:$LD_LIBRARY_PATH"

eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"

bindkey '' autosuggest-accept

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
