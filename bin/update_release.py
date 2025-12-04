#!/usr/bin/env python3

import os
from pathlib import Path
from ruamel.yaml import YAML

yaml = YAML()

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
            contents = yaml.load(f.read())
            jobs = contents['jobs']['release']['strategy']['matrix']['job']

            jobs.append({
                "runner": "ubuntu-24-04"
                })


        

if __name__ == "__main__":
    main()
