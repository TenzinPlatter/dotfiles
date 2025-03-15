alias rbug="RUST_BACKTRACE=1"
alias xh="hx"
alias l='eza -lh --icons auto' # long list
alias ls='eza -1 --icons auto -a' # short list
alias sl='ls'
alias ll='eza -lha --icons auto --sort name --group-directories-first' # long list all
alias ld='eza -lhD --icons auto' # long list dirs
alias lt='eza --icons auto --tree' # list folder as tree
alias hxf='hx $(fzf)'
alias hxfd='hx $(fzfd)'
alias hxsh='hx ~/.zshrc && source ~/.zshrc'
alias hxenv='hx ~/.zshenv && source ~/.zshenv'
alias hxhl='hx ~/.config/hypr/.'
alias db='distrobox'
alias dbr='distrobox enter ros2'
alias ff='firefox'
alias lg='lazygit'
alias hxcf='hx ~/.config/helix/.'
alias cat='bat'
alias p='python'
alias tmuxkill="tmux kill-session"
alias cl='clear'
alias fzfd="find . -type d -print | fzf"
alias installvencord='sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"'
alias pkginfo="pacman -Qq | fzf --preview 'pacman -Qil {} | bat -fpl yml' --layout=reverse  --bind 'enter:execute(pacman -Qil {} | less)'"
alias nvsw="cd ~/.local/state/nvim/swap"
alias tx="tmux"
alias sourceenv="source env/bin/activate"
alias hxtx="hx ~/.tmux.conf"
alias srtx="tmux source ~/.tmux.conf"
alias cdapp="cd /usr/share/applications"
alias cmakecompcomm="cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build"
alias update="sudo apt update && sudo apt upgrade"
alias caps="sudo nohup casp2esc ; disown"
alias sr="source ~/coding/siri/sirius-software-source-install/ros2_humble/install/setup.zsh"
alias srl="source ./install/setup.zsh"
alias cbuild="colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
alias mkdir="mkdir -p"
alias dbr="distrobox enter ros"
alias cr="cargo run"

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

hx() {
	if [[ $# -eq 0 ]]; then
		helix .
	else
		helix "$@"
	fi
}

findbin() {
  local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
  local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
  if (( ${#entries[@]} > 0 )); then
      printf "${bright}$1${reset} may be found in the following packages:\n"
      local pkg
      for entry in "${entries[@]}"; do
          local fields=( ${(0)entry} )
          if [[ "$pkg" != "${fields[2]}" ]]; then
              printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
          fi
          printf '    /%s\n' "${fields[4]}"
          pkg="${fields[2]}"
      done
  fi
  return 127
}

path=(
	$PATH
	~/.cargo/bin
	~/.npm-packages
	~/.scripts
	/home/tenzin/.spicetify
	/home/tenzin/.local/bin
	~/scripts
	/usr/bin
)

. "$HOME/.cargo/env"

export PATH="${(j/:/)path}"
export EDITOR="helix"

# so gazebo works
export QT_QPA_PLATFORM=xcb

eval "$(zoxide init zsh --cmd cd)"
eval "$(fzf --zsh)"

bindkey -v
bindkey '' autosuggest-accept

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
