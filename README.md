Run:
```
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

# Dotfile Watcher
Automatically commits changes and pushes to current branch

## Setup
    1. Put git repo on machine specific branch
    2. Make sure it is setup to track a remote branch
    3. Enable user systemd service
    - Debug any issues by looking at logs with: journalctl --user -u dotfiles-watcher.service -f
    - Restart after script changes with: systemctl restart --user dotfiles-watcher.service
