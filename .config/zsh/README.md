# ZSH Module Loader

A dynamic module loading system for Zsh that uses YAML configuration to manage shell modules.

## Overview

The module loader consists of three main components:

1. **`modules.yaml`** - YAML configuration defining which modules to load
2. **`load-modules.py`** - Python script that parses YAML and generates source commands
3. **`load-modules.zsh`** - Zsh wrapper that executes the Python script and optionally profiles module load times

## How It Works

### 1. Configuration (`modules.yaml`)

The YAML structure maps directly to your directory structure. Each indentation level represents a subdirectory:

```yaml
user:
  - "*"           # Load all .zsh files in user/ recursively

aliases:
  - git          # Load aliases/git.zsh (extension optional)
  - nvim.zsh     # Load aliases/nvim.zsh (explicit extension)

env:
  rust: rust     # Load env/rust/rust.zsh

disabled:        # Modules to skip
  programs:
    - bat
```

### 2. Python Parser (`load-modules.py`)

The Python script:
- Reads `modules.yaml` from `$ZDOTDIR` (defaults to `~/.config/zsh`)
- Recursively traverses the YAML structure using indentation as directory paths
- Handles smart extension matching (finds `.zsh` files automatically)
- Supports wildcard (`*`) to recursively load all `.zsh` files in a directory
- Filters out disabled modules
- Outputs `source '/path/to/file.zsh'` commands for Zsh to execute

**Key Functions:**
- `find_file_with_extension()` - Smart file lookup (adds `.zsh` if needed)
- `collect_files_from_section()` - Recursively collects files based on YAML structure
- Handles `disabled:` section to skip specific modules

### 3. Zsh Loader (`load-modules.zsh`)

The Zsh function:
- Invokes the Python script via `python3 load-modules.py`
- Evaluates the output (source commands) using `eval`
- Supports `--profile` flag to measure and display load times for each module

**Usage:**
```zsh
# Normal loading
source "${ZDOTDIR:-$HOME}/load-modules.zsh"

# Profile mode (shows timing table)
source "${ZDOTDIR:-$HOME}/load-modules.zsh" --profile
```

### 4. Integration (`.zshrc`)

The loader is called in `.zshrc`:
```zsh
source "${ZDOTDIR:-$HOME}/load-modules.zsh"
```

## Features

### Smart Extension Handling
Files can be specified with or without `.zsh` extension:
```yaml
user:
  - aliases    # Finds aliases.zsh automatically
  - fns.zsh    # Explicit extension also works
```

### Wildcard Loading
Use `*` to load all `.zsh` files recursively:
```yaml
user:
  - "*"        # Loads all .zsh files in user/ and subdirectories
```

### Disable Modules
Two ways to disable modules:

1. **YAML `disabled:` section:**
```yaml
disabled:
  programs:
    - bat
    - zoxide
```

2. **Environment variable:**
```bash
export ZSH_DISABLED_MODULES="bat,zoxide,fzf"
```

### Profiling
Measure load times to optimize shell startup:
```zsh
load_modules --profile
```

Output:
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                          Module Load Profiling Results                        ║
╠════════════════════════════════════════════════════════════════════════════════╣
║ Module                                                             Time (ms) ║
╠════════════════════════════════════════════════════════════════════════════════╣
║ /home/user/.config/zsh/user/aliases/git.zsh                              12 ║
║ /home/user/.config/zsh/user/env/rust.zsh                                  8 ║
╠════════════════════════════════════════════════════════════════════════════════╣
║ TOTAL                                                                     20 ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

## Directory Structure

```
~/.config/zsh/
├── load-modules.zsh      # Zsh loader function
├── load-modules.py       # Python YAML parser
├── modules.yaml          # Module configuration
├── user/                 # User modules
│   ├── aliases/
│   ├── env/
│   ├── fns/
│   └── programs/
├── conf.d/              # System configs
└── functions/           # Zsh functions
```

## Examples

### Load specific files
```yaml
aliases:
  - git
  - nvim

env:
  - rust
  - node
```

### Load entire directories
```yaml
user:
  aliases:
    - "*"    # All files in user/aliases/
  env:
    - "*"    # All files in user/env/
```

### Nested directories
```yaml
conf.d:
  hyde:
    - env      # Loads conf.d/hyde/env.zsh
    - prompt   # Loads conf.d/hyde/prompt.zsh
```

### Disable specific modules
```yaml
programs:
  - fzf
  - bat
  - zoxide

disabled:
  programs:
    - bat    # bat won't be loaded
```
