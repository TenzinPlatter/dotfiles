#!/usr/bin/env bash
# Remove all .pixi/ environment dirs under a root (default: $HOME).
set -euo pipefail
root="${1:-$HOME}"
find "$root" -type d -name .pixi -prune -print -exec rm -rf {} +
