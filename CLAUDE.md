# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages configuration files across multiple machines using a sophisticated automated git workflow. The repository uses git submodules for modular configuration management and includes an automated file watcher system.

## Architecture

### Dotfiles Structure
- **Main repository**: Contains top-level configuration files (.zshrc, .tmux.conf, etc.) and coordinates submodules
- **Git submodules**: Each major tool has its own repository:
  - `.config/helix` → helix_conf.git (Helix editor configuration)
  - `.config/nvim` → NeovimConfig.git (Neovim configuration)  
  - `.zsh` → zsh.git (Zsh configuration and plugins)
  - `scripts` → scripts repository (utility scripts)

### Machine-Specific Branching
The repository uses machine-specific branches (like `pc_arch`) rather than `main` for different machines. This allows machine-specific configurations while maintaining shared base configurations.

### Automated Git Workflow
The core automation is handled by `scripts/dotfile_watcher.py`, a sophisticated Python daemon that:

1. **File Monitoring**: Watches all files in the dotfiles directory using the `watchdog` library
2. **Intelligent Commits**: 
   - Squashes multiple file changes within 60 seconds into single commits
   - Handles both main repository and submodule changes
   - Automatically commits existing uncommitted changes on startup
3. **Dual Repository Management**: 
   - Commits changes in submodules first, then updates submodule references in main repo
   - Pushes to whatever branch each repository is currently on
4. **Remote Synchronization**: 
   - Pushes all commits automatically
   - Fetches from remotes every 10 minutes and sends desktop notifications for upstream changes
5. **Smart Exclusions**: Ignores git internal files, temporary files, and gitignore patterns

## Common Commands

### Systemd Service Management
The file watcher runs as a user systemd service:

```bash
# Start/stop the watcher
systemctl --user start dotfiles-watcher.service
systemctl --user stop dotfiles-watcher.service
systemctl --user restart dotfiles-watcher.service

# Enable auto-start on login
systemctl --user enable dotfiles-watcher.service

# Check status and logs
systemctl --user status dotfiles-watcher.service
journalctl --user -u dotfiles-watcher.service -f
journalctl --user -u dotfiles-watcher.service --since "10 minutes ago"
```

### Initial Setup
```bash
# Clone and set up dotfiles
git clone git@github.com:TenzinPlatter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .

# Set up machine-specific branch and tracking
git checkout -b $(hostname)
git push -u origin $(hostname)
```

### Git Submodule Management
```bash
# Update all submodules to latest
git submodule update --remote

# Add a new submodule
git submodule add <url> <path>

# Check submodule status
git submodule status
```

## Development Notes

### File Watcher Configuration
Key configuration constants in `scripts/dotfile_watcher.py`:
- `COMMIT_DELAY = 60`: Seconds to wait before committing (allows squashing multiple changes)
- `FETCH_INTERVAL = 600`: Seconds between remote fetches (10 minutes)

### Exclusion Patterns
The watcher automatically excludes:
- Git internal files (.git/, index.lock, COMMIT_EDITMSG, etc.)
- Editor temporary files (numeric filenames, .swp, .swo, etc.)
- Files matching gitignore patterns in each repository

### Debugging
- All watcher output goes to journalctl with detailed error logging
- Debug messages show excluded files and git command failures
- Service automatically restarts on failures with 10-second delay

### Machine-Specific Files
Files that should be machine-specific are gitignored (e.g., `.config/kitty/machine.conf`).

### Desktop Notifications
The watcher sends desktop notifications via `notify-send` for:
- Main repository commits (not submodule commits)
- Remote changes detected during periodic fetches
