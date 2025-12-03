#!/usr/bin/env python3

import os
from pathlib import Path
import yaml

def main():
    cwd = Path(os.getcwd())
    release_files = []
    for subdir in cwd.glob("./*"):
        if not subdir.is_dir():
            continue

        release = subdir / ".github" / "workflows" / "release.yml"
        if not release.is_file():
            print(f"Subdir: {subdir} does not contain a release file")
            continue

        release_files.append(subdir)

    for r in release_files:
        with open(r, "+") as f:
            contents = yaml.safe_load(f.read())

        

if __name__ == "__main__":
    main()
