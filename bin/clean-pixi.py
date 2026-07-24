#!/usr/bin/env python3
"""Remove all project .pixi/ environment dirs under a root (default: $HOME).

Never touch ~/.pixi itself - that is the pixi installation (bin, global envs).
"""
import os
import shutil
import subprocess
import sys
from pathlib import Path


def dir_size(path: Path) -> int:
    total = 0
    for dirpath, _, files in os.walk(path):
        for f in files:
            fp = Path(dirpath) / f
            try:
                total += fp.lstat().st_size
            except OSError:
                pass  # ponytail: race with rm/broken symlink, just skip
    return total


def human(n: int) -> str:
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if n < 1024:
            return f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}PiB"


def main() -> None:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else Path.home())
    installation = Path.home() / ".pixi"

    # fd --prune stops descending into matched .pixi dirs (their nested files aren't hits)
    out = subprocess.run(
        ["fd", "-H", "-t", "d", "-a", "--prune", r"^\.pixi$", str(root)],
        capture_output=True, text=True, check=True,
    ).stdout

    count = 0
    freed = 0
    for line in out.splitlines():
        target = Path(line)
        if target == installation:
            continue
        size = dir_size(target)
        shutil.rmtree(target, ignore_errors=True)
        count += 1
        freed += size
        print(f"removed {target} ({human(size)})")

    print(f"\n{count} env dir(s) removed, {human(freed)} freed")


if __name__ == "__main__":
    main()
