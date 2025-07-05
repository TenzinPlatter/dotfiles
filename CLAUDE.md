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
The automation is now handled by the separate [Watcher](https://github.com/TenzinPlatter/watcher) package, a sophisticated Python daemon that:

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
5. **Hierarchical Ignore Patterns**: 
   - Global ignore file (`~/.config/watcher/ignore`) for all watchers
   - Project-specific ignore patterns in configuration files
   - Respects gitignore files in repositories

## Common Commands

### Watcher Service Management
The file watcher is now managed using the Watcher package:

```bash
# Install watcher package
git clone https://github.com/TenzinPlatter/watcher.git ~/coding/python/watcher
cd ~/coding/python/watcher
pip install --user -e .

# Initialize watcher for dotfiles
watcher init dotfiles --watch-dir ~/.dotfiles --repo-dir ~/.dotfiles

# Start/stop the watcher
watcher up dotfiles
watcher down dotfiles

# Check status and logs
watcher status dotfiles
watcher logs dotfiles -f
watcher logs dotfiles --since "10 minutes ago"

# Edit configuration
watcher edit-config dotfiles
watcher edit-ignore
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

# Install and configure watcher
git clone https://github.com/TenzinPlatter/watcher.git ~/coding/python/watcher
cd ~/coding/python/watcher
pip install --user -e .
watcher init dotfiles --watch-dir ~/.dotfiles --repo-dir ~/.dotfiles
watcher up dotfiles
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

### Watcher Configuration
Configuration is stored in `~/.config/watcher/dotfiles.yaml`:
- `commit_delay`: Seconds to wait before committing (default: 60)
- `fetch_interval`: Seconds between remote fetches (default: 600)
- `auto_push`: Automatically push commits (default: true)
- `enable_notifications`: Desktop notifications (default: true)

### Ignore Patterns
The watcher uses hierarchical ignore patterns:
- **Global ignore**: `~/.config/watcher/ignore` (applies to all watchers)
- **Config ignore**: `ignore_patterns` in the YAML config file
- **Additional ignore files**: Listed in `ignore_files` config option
- **Gitignore files**: Repository `.gitignore` files (if `respect_gitignore: true`)

### Debugging
- All watcher output goes to journalctl with detailed error logging
- Use `watcher logs dotfiles -f` to follow logs in real-time
- Use `watcher test-ignore <file>` to test ignore patterns
- Use `watcher status dotfiles` to check configuration validation

### Machine-Specific Files
Files that should be machine-specific are gitignored (e.g., `.config/kitty/machine.conf`).

### Desktop Notifications
The watcher sends desktop notifications via `notify-send` for:
- Main repository commits (configurable with `notify_on_commit`)
- Remote changes detected during periodic fetches (configurable with `notify_on_remote_changes`)
- Overall notifications can be disabled with `enable_notifications: false`
