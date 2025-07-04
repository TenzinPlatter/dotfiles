# Personal Dotfiles

A comprehensive dotfiles setup with automated git workflow for managing configuration files across multiple machines.

## Features

- **Modular Configuration**: Uses git submodules for tool-specific configs (Neovim, Helix, Zsh)
- **Machine-Specific Branches**: Different configurations per machine while sharing base configs
- **Automated Commits**: File watcher automatically commits and pushes changes
- **Smart Squashing**: Groups multiple file changes into single, meaningful commits
- **Desktop Notifications**: Alerts for commits and remote changes
- **Intelligent Exclusions**: Ignores temporary files, git internals, and gitignore patterns

## Prerequisites

Before installation, ensure you have:

- **Git** with SSH key configured for GitHub
- **GNU Stow** for symlink management
- **Python 3** with `watchdog` library
- **systemd** (Linux user services)
- **notify-send** (usually from libnotify package)

Install dependencies on Arch Linux:
```bash
sudo pacman -S git stow python python-watchdog libnotify
```

## Installation

### 1. Clone Repository
```bash
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Initialize Submodules
```bash
git submodule update --init --recursive
```

### 3. Create Machine-Specific Branch
```bash
# Create and switch to machine-specific branch
git checkout -b $(hostname)

# Set up remote tracking
git push -u origin $(hostname)
```

### 4. Install Dotfiles
```bash
# Create symlinks to home directory
stow .
```

### 5. Install Python Dependencies
```bash
pip install watchdog
```

## Dotfile Watcher Setup

The automated file watcher monitors changes and handles git operations.

### Enable Systemd Service
```bash
# Enable auto-start on login
systemctl --user enable dotfiles-watcher.service

# Start the service
systemctl --user start dotfiles-watcher.service

# Check status
systemctl --user status dotfiles-watcher.service
```

### Service Management
```bash
# View real-time logs
journalctl --user -u dotfiles-watcher.service -f

# Restart service (after script changes)
systemctl --user restart dotfiles-watcher.service

# Stop service
systemctl --user stop dotfiles-watcher.service
```

## How It Works

### Automated Workflow
1. **File Monitoring**: Watches `~/.dotfiles` for any file changes
2. **Smart Delay**: Waits 60 seconds after last change to group multiple edits
3. **Dual Commits**: 
   - First commits changes in relevant submodule
   - Then updates submodule reference in main repo
4. **Auto Push**: Pushes all commits to current branch
5. **Remote Sync**: Fetches every 10 minutes and notifies of upstream changes

### Commit Messages
- Single file: `"update filename.conf in location"`
- Multiple files: `"update 3 files, add 1 file in nvim"`
- New files: `"add new-script.sh in scripts"`

### Excluded Files
Automatically ignores:
- Git internals (`.git/`, `index.lock`, etc.)
- Editor temporaries (`.swp`, numeric temp files)
- Backup files (`~`, `.bak`, `.orig`)
- Files matching `.gitignore` patterns

## Submodules

| Path | Repository | Description |
|------|------------|-------------|
| `.config/nvim` | NeovimConfig | Neovim configuration |
| `.config/helix` | helix_conf | Helix editor configuration |
| `.zsh` | zsh | Zsh configuration and plugins |
| `scripts` | scripts | Utility scripts |

### Managing Submodules
```bash
# Update all submodules to latest
git submodule update --remote

# Check submodule status
git submodule status

# Add new submodule
git submodule add <repository-url> <path>
```

## Troubleshooting

### Service Not Starting
```bash
# Check service status and logs
systemctl --user status dotfiles-watcher.service
journalctl --user -u dotfiles-watcher.service --since "10 minutes ago"

# Common fixes
systemctl --user daemon-reload
systemctl --user restart dotfiles-watcher.service
```

### Commits Not Happening
- Check if files are being excluded (check logs)
- Verify git remote tracking is set up
- Ensure Python watchdog library is installed

### Push Failures
```bash
# Check if branch has upstream tracking
git branch -vv

# Set up tracking if missing
git push -u origin $(git branch --show-current)
```

### Desktop Notifications Not Working
- Install libnotify: `sudo pacman -S libnotify`
- Test manually: `notify-send "Test" "Message"`
- Check if running in graphical session

## Configuration

Edit `scripts/dotfile_watcher.py` to customize:
- `COMMIT_DELAY = 60`: Seconds to wait before committing
- `FETCH_INTERVAL = 600`: Seconds between remote fetches
- Exclusion patterns in `excluded_patterns` list
