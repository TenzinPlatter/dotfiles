bindkey -e

export EDITOR=nvim

source "${ZDOTDIR:-$HOME}/load-modules.zsh"

path=(
    $PATH
    ~/.cargo/bin
    ~/.npm-packages
    ~/scripts
    /home/tenzin/.spicetify
    /home/tenzin/.local/bin
    /usr/bin
    /usr/local/bin
    /usr/local/cuda-13.0/bin
    /home/tenzin/bin
    /home/tenzin/.config/superpowers/skills/skills/using-skills
    /home/tenzin/go/bin
)

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=""

export EDITOR="nvim"
export TERMINAL="kitty"
export NIXPKGS_ALLOW_UNFREE=1

export POKEGO_CACHE_AGE=300
export PATH="${(j/:/)path}"

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-13.0/lib64
export LD_FLAGS="-fuse-ld=mold"

export MANPAGER='nvim +Man!'   

setopt NO_AUTO_CD

autoload -z edit-command-line

zle -N menu-search
zle -N recent-paths
zle -N edit-command-line

bindkey '^ ' autosuggest-accept
bindkey '' edit-command-line

# fn to run on change pwd
chpwd() {
  set_platform_module
}

stty -ixon

[[ -f  "$HOME/.local/share/../bin/env" ]] && . "$HOME/.local/share/../bin/env"
