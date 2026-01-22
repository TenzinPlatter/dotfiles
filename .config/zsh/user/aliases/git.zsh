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
  if [ $# -lt 1 ]; then
    echo "Usage: gcd <repo-url>"
    return 1
  fi

  # Get list of directories before cloning
  local before=$(ls -1d */ 2>/dev/null | sort)

  # Clone the repo
  git clone "$1" || return 1

  # Get list of directories after cloning
  local after=$(ls -1d */ 2>/dev/null | sort)

  # Find the new directory
  local new_dir=$(comm -13 <(echo "$before") <(echo "$after") | head -n1)

  if [ -n "$new_dir" ]; then
    cd "$new_dir"
  else
    echo "Error: Could not determine cloned directory"
    return 1
  fi
}
