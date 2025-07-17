# Dotfiles

Self-managing dotfiles with automated git workflow. Change a config file, get automatic commits and pushes.

## What it does

- Uses git submodules for modular configs (nvim, helix, zsh, scripts)
- Machine-specific branches so your desktop and laptop can have different configs
- File watcher auto-commits and pushes changes (with 60s delay for squashing)
- Desktop notifications for commits and remote changes
- Excludes temp files, git internals, and respects gitignore

## Setup

You'll need: `git`, `stow`, `python`, `python-watchdog`, `libnotify`

```bash
# Arch Linux
sudo pacman -S git stow python python-watchdog libnotify

# Ubuntu/Debian
sudo apt install git stow python3 python3-pip libnotify-bin
pip3 install watchdog
```

```bash
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive

# Create machine-specific branch
git checkout -b $(hostname)
git push -u origin $(hostname)

# Install dotfiles
stow .

# Start the file watcher
systemctl --user enable --now dotfiles-watcher.service
```

## Usage

```bash
# Watch logs
journalctl --user -u dotfiles-watcher.service -f

# Restart after changes
systemctl --user restart dotfiles-watcher.service
```

## How it works

Edit a file → waits 60s without making changes → commits to submodule (if change was in a submodule) → updates main repo → pushes both.

Also fetches every 10 minutes and sends desktop notifications for remote changes.

## Common issues

**Service won't start**: Check logs with `journalctl --user -u dotfiles-watcher.service`

**No commits happening**: Check if your branch has upstream tracking (`git branch -vv`)

**Push fails**: Set up tracking with `git push -u origin $(git branch --show-current)`

**Config**: Edit timing/exclusions in `scripts/dotfile_watcher.py`
