#!/usr/bin/env bash
# Remove all project .pixi/ environment dirs under a root (default: $HOME), report space freed.
# Never touch ~/.pixi itself - that is the pixi installation (bin, global envs).
set -euo pipefail
root="${1:-$HOME}"

mapfile -t dirs < <(find "$root" -type d -name .pixi ! -path "$HOME/.pixi" ! -path "$HOME/.pixi/*" -prune 2>/dev/null)
if [ ${#dirs[@]} -eq 0 ]; then
  echo "No .pixi dirs under $root"
  exit 0
fi

freed=$(du -sc "${dirs[@]}" | tail -1 | cut -f1)  # KiB
printf '%s\n' "${dirs[@]}"
rm -rf "${dirs[@]}"
echo "Freed $(numfmt --to=iec --from-unit=1024 "$freed") across ${#dirs[@]} dirs"
