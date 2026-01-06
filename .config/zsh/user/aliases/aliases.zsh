[[ -f ~/.zsh/machine.zsh ]] && source ~/.zsh/machine.zsh

alias cpwd="pwd | tr -d '\n' | wl-copy"

alias tc="toad -a claude"

alias cl="claude"
alias wp="wallpaper-picker.sh"

alias capson="sudo systemctl enable --now udevmon"
alias capsoff="sudo systemctl disable --now udevmon"

alias dk="docker"
alias dcu="docker compose up -d"
alias dcub="docker compose up -d --build"
alias dkc="docker compose"

alias srz="source $ZDOTDIR/.zshrc"
alias new="exec zsh"

alias killpgad="kill $(pidof /home/tenzin/.scripts/open_pgadmin.sh)"
alias workoff="deactivate"
alias cinit='eval "$(/home/tenzin/anaconda3/bin/conda shell.zsh hook)" && conda init'
alias pgres="sudo -u postgres -i /bin/bash"

alias gdb="gdb --tui"
alias cx="chmod u+x"
alias ff="pokego -r 1 --no-title | fastfetch --file-raw -"
alias c="clear"
alias cat='bat'
alias mk="make"
alias cc="clang"
alias p='python'
alias python="python3"
alias mkdir="mkdir -p"
alias rmd="rm -rf"

alias db='distrobox'
alias dbr="distrobox enter ros"
alias dbs="distrobox enter siri"

alias tmuxkill="tmux kill-session"
alias srtx="tmux source ~/.tmux.conf"
alias tx="tmux"

alias pkginfo="pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse  --bind 'enter:execute(pacman -Qil {} | less)'"

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
