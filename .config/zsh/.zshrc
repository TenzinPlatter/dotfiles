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
    /usr/local/go/bin
    /home/tenzin/.config/superpowers/skills/skills/using-skills
)

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=""

export EDITOR="nvim"
export TERMINAL="kitty"
export NIXPKGS_ALLOW_UNFREE=1
export cc="clang"

export PATH="${(j/:/)path}"
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-13.0/lib64
export POKEGO_CACHE_AGE=300

export MANPAGER='nvim +Man!'   

setopt NO_AUTO_CD

autoload -z edit-command-line

zle -N menu-search
zle -N recent-paths
zle -N edit-command-line

bindkey '^ ' autosuggest-accept
bindkey '' edit-command-line

[[ -f  "$HOME/.local/share/../bin/env" ]] && . "$HOME/.local/share/../bin/env"

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/home/tenzin/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/home/tenzin/anaconda3/etc/profile.d/conda.sh" ]; then
#         . "/home/tenzin/anaconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/home/tenzin/anaconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

