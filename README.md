# Dotfiles

Personal dotfiles repository with automated git workflow using the [Watcher](https://github.com/TenzinPlatter/watcher) package.

## What it includes

- Uses git submodules for modular configs (nvim, helix, zsh, scripts)
- Machine-specific branches so your desktop and laptop can have different configs
- Automated file watching and git commits using the Watcher package
- Desktop notifications for commits and remote changes

## Setup

### Prerequisites

You'll need: `git`, `stow`, `python3`, `pip`

```bash
# Arch Linux
sudo pacman -S git stow python python-pip

# Ubuntu/Debian
sudo apt install git stow python3 python3-pip
```

### Install Dotfiles

```bash
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive

# Create machine-specific branch
git checkout -b $(hostname)
git push -u origin $(hostname)

# Install dotfiles
stow .
```

### Install and Setup Watcher

```bash
# Install the watcher package
git clone https://github.com/TenzinPlatter/watcher.git ~/coding/python/watcher
cd ~/coding/python/watcher
pip install --user -e .

# Initialize watcher for dotfiles
watcher init dotfiles --watch-dir ~/.dotfiles --repo-dir ~/.dotfiles

# Start watching
watcher up dotfiles
```

## Usage

### File Watcher Management

```bash
# Check status
watcher status dotfiles

# View logs
watcher logs dotfiles

# Stop watching
watcher down dotfiles

# Restart after config changes
watcher down dotfiles && watcher up dotfiles
```

### Configuration

The watcher configuration is stored in `~/.config/watcher/dotfiles.yaml`. You can edit it with:

```bash
watcher edit-config dotfiles
```

Key settings:
- `commit_delay`: Wait time before committing (default: 60 seconds)
- `fetch_interval`: Interval between remote fetches (default: 10 minutes)
- `auto_push`: Automatically push commits (default: true)
- `enable_notifications`: Desktop notifications (default: true)

### Global Ignore Patterns

Edit the global ignore file to exclude files from all watcher instances:

```bash
watcher edit-ignore
```

## How it works

1. **File Change Detection**: Watcher monitors the ~/.dotfiles directory
2. **Intelligent Squashing**: Waits 60 seconds after last change, then combines multiple file changes into a single commit
3. **Submodule Handling**: Commits to submodules first, then updates submodule references in main repo
4. **Auto-Push**: Pushes commits automatically to your machine-specific branch
5. **Remote Monitoring**: Fetches every 10 minutes and notifies of remote changes

## Multiple Machine Setup

Each machine should use its own branch:

```bash
# On machine 1
git checkout -b desktop
git push -u origin desktop
watcher init dotfiles --watch-dir ~/.dotfiles

# On machine 2  
git checkout -b laptop
git push -u origin laptop
watcher init dotfiles --watch-dir ~/.dotfiles
```

## Troubleshooting

### Service Issues

```bash
# Check watcher status
watcher status dotfiles

# View detailed logs
watcher logs dotfiles -f

# Test ignore patterns
watcher test-ignore some/file.txt dotfiles
```

### Git Issues

```bash
# Check branch tracking
git branch -vv

# Set up tracking if missing
git push -u origin $(git branch --show-current)

# Manual git operations still work normally
git status
git add .
git commit -m "manual commit"
```

### Configuration Issues

```bash
# Validate configuration
watcher status dotfiles

# Edit configuration
watcher edit-config dotfiles

# Edit global ignore patterns
watcher edit-ignore
```

For more details about the Watcher package, see the [Watcher documentation](https://github.com/TenzinPlatter/watcher).
