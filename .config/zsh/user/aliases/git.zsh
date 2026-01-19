alias lg='lazygit'
alias gs='git stash'
alias ga='git add '
alias gb='git branch '
alias gp='git push'
alias gl='git pull'
alias gd='git diff --output-indicator-new=" " --output-indicator-old=" "' 
alias gco='git checkout '
alias gcob='git checkout -b '
alias gk='gitk --all&'
alias gx='gitx --all'
alias gc='git clone'
alias pca="pre-commit run --all"
alias pcf="pre-commit run --files"
alias pcr="pre-commit run"

# Clone a repo and cd into the directory
gcd() {
  if [ $# -lt 2 ]; then
    echo "Usage: gccd <repo-url> <directory-name>"
    return 1
  fi
  git clone "$1" "$2" && cd "$2"
}
