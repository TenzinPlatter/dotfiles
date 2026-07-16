#!/usr/bin/env bash
# Remove all project .pixi/ environment dirs under a root (default: $HOME).
# Never touch ~/.pixi itself - that is the pixi installation (bin, global envs).
set -euo pipefail
root="${1:-$HOME}"
find "$root" -type d -name .pixi ! -path "$HOME/.pixi" ! -path "$HOME/.pixi/*" \
  -prune -print -exec rm -rf {} +
