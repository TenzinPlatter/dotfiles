Run:
```
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

# Dotfile Watcher
Automatically commits changes and pushes to current branch

## Setup
    - Put git repo on machine specific branch
    - Make sure it is setup to track a remote branch
    - Enable user systemd service
    - Debug any issues by looking at logs in: journalctl --user -u dotfiles-watcher.service -f
