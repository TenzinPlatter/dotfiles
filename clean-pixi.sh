#!/usr/bin/env bash
# Remove all .pixi/ environment dirs under a root (default: $HOME), report space freed.
set -euo pipefail
root="${1:-$HOME}"

mapfile -t dirs < <(find "$root" -type d -name .pixi -prune 2>/dev/null)
if [ ${#dirs[@]} -eq 0 ]; then
  echo "No .pixi dirs under $root"
  exit 0
fi

freed=$(du -sc "${dirs[@]}" | tail -1 | cut -f1)  # KiB
printf '%s\n' "${dirs[@]}"
rm -rf "${dirs[@]}"
echo "Freed $(numfmt --to=iec --from-unit=1024 "$freed") across ${#dirs[@]} dirs"
