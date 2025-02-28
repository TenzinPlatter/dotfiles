alias l='eza -lh --icons auto' # long list
alias ls='eza -1 --icons auto -a' # short list
alias sl='ls'
alias ll='eza -lha --icons auto --sort name --group-directories-first' # long list all
alias ld='eza -lhD --icons auto' # long list dirs
alias lt='eza --icons auto --tree' # list folder as tree
alias nvf='nv $(fzf)'
alias nvfd='nv $(fzfd)'
alias nvsh='nvim ~/.zshrc && source ~/.zshrc'
alias nvenv='nvim ~/.zshenv && source ~/.zshenv'
alias nvhl='nvim ~/.config/hypr/.' alias db='distrobox'
alias dbr='distrobox enter ros2'
alias ff='firefox'
alias lg='lazygit'
alias nvcf='nvim ~/.config/nvim/.' alias lgnv='lazygit -p ~/.config/nvim/' alias cat='bat'
alias p='python'
alias tmuxkill="tmux kill-session"
alias cl='clear'
alias sr="source /opt/ros/humble/setup.zsh"
alias fzfd="find . -type d -print | fzf"
alias installvencord='sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"'
alias pkginfo="pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse  --bind 'enter:execute(pacman -Qil {} | less)'"
alias nvsw="cd ~/.local/state/nvim/swap"
alias tx="tmux"
alias sourceenv="source env/bin/activate"
alias nvtx="nvim ~/.tmux.conf"
alias srtx="tmux source ~/.tmux.conf"
alias cdapp="cd /usr/share/applications"
alias cmakecompcomm="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build"
alias update="sudo apt update && sudo apt upgrade"
alias caps="sudo nohup casp2esc ; disown"
alias sr="source ~/coding/siri/sirius-software-source-install/ros2_humble/install/setup.zsh"
alias cbuild="colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gP='git push'
alias gp='git pull'
alias gc='git commit'
alias gd='git diff'
alias gco='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'
alias gh='git hist'

nv() {
	if [[ $# -eq 0 ]]; then
		nvim .
	else
		nvim "$@"
	fi
}

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '' autosuggest-accept

# so gazebo works
export QT_QPA_PLATFORM=xcb

path=(
	$PATH
	~/.cargo/bin
	~/.npm-packages
	~/.scripts
	/home/tenzin/.spicetify
	/home/tenzin/.local/bin
)

export PATH="${(j/:/)path}"

eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"

bindkey -v

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
