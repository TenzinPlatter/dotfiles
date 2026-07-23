#!/usr/bin/env python3
"""Run `pixi update` next to every pixi.toml under CWD, reporting pass/fail."""
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
manifests = [p for p in root.rglob("pixi.toml") if ".pixi" not in p.parts]

ok, failed = [], []
for m in manifests:
    d = m.parent
    r = subprocess.run(["pixi", "update"], cwd=d, capture_output=True, text=True)
    (ok if r.returncode == 0 else failed).append((d, r.stderr.strip()))
    print(f"{'✓' if r.returncode == 0 else '✗'} {d}")

print(f"\n{len(ok)} ok, {len(failed)} failed")
for d, err in failed:
    print(f"\n--- {d}\n{err}")

sys.exit(1 if failed else 0)
