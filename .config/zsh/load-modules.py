#!/usr/bin/env python3

import yaml
import os
import sys
from pathlib import Path

def find_file_with_extension(dir_path, basename):
    """Find a file with smart extension handling."""
    # If basename already has an extension, use it directly
    if '.' in basename:
        file_path = dir_path / basename
        return file_path if file_path.is_file() else None
    
    # Find all files that match the basename (without extension)
    matching_files = list(dir_path.glob(f"{basename}.*"))
    
    if len(matching_files) == 0:
        return None
    elif len(matching_files) == 1:
        return matching_files[0]
    else:
        # Multiple files with same basename but different extensions
        print(f"Error: Multiple files found for '{basename}' in {dir_path}:", file=sys.stderr)
        for f in matching_files:
            print(f"  {f.name}", file=sys.stderr)
        print("Please specify the full filename with extension.", file=sys.stderr)
        sys.exit(1)

def load_modules():
    zdotdir = Path(os.environ.get("ZDOTDIR", Path.home() / ".config" / "zsh"))
    config_file = zdotdir / "modules.yaml"
    zsh_dir = zdotdir

    if not config_file.exists():
        return

    try:
        with open(config_file, "r") as f:
            config = yaml.safe_load(f)
    except Exception as e:
        print(f"Error reading YAML: {e}", file=sys.stderr)
        return

    sourced_files = []
    disabled_files = set()

    def collect_files_from_section(data, path_parts=[], file_set=None):
        """Recursively collect files from YAML structure using indentation levels as directory paths."""
        if file_set is None:
            file_set = []

        for key, value in data.items():
            current_path = path_parts + [key]

            if isinstance(value, dict):
                # Nested dictionary - recurse deeper
                collect_files_from_section(value, current_path, file_set)
            else:
                # This is a file list - process it
                dir_path = zsh_dir / "/".join(current_path)

                if not dir_path.exists():
                    continue

                # Handle list of files
                if isinstance(value, list):
                    file_list = value
                else:
                    file_list = [value]

                for filename in file_list:
                    if filename == "*":
                        # Collect all .zsh files in directory and subdirectories recursively
                        for zsh_file in dir_path.rglob("*.zsh"):
                            if zsh_file.is_file():
                                file_set.append(str(zsh_file))
                    else:
                        # Find file with smart extension handling
                        file_path = find_file_with_extension(dir_path, filename)
                        if file_path:
                            file_set.append(str(file_path))

        return file_set

    # Process enabled modules
    enabled_sections = {k: v for k, v in config.items() if k != 'disabled'}
    if enabled_sections:
        sourced_files = collect_files_from_section(enabled_sections)

    # Process disabled modules
    if 'disabled' in config:
        disabled_files_list = collect_files_from_section(config['disabled'])
        disabled_files = set(disabled_files_list)

    # Process environment variable disabled modules
    env_disabled = os.environ.get("ZSH_DISABLED_MODULES", "")
    if env_disabled:
        env_disabled_patterns = [pattern.strip() for pattern in env_disabled.split(",")]
        for pattern in env_disabled_patterns:
            # Convert simple patterns to file paths
            for source_file in sourced_files:
                if pattern in source_file or source_file.endswith(f"/{pattern}.zsh") or source_file.endswith(f"/{pattern}"):
                    disabled_files.add(source_file)

    # Filter out disabled files
    final_files = [f for f in sourced_files if f not in disabled_files]

    # Output the files to source (zsh will read this)
    for file_path in final_files:
        print(f"source '{file_path}'")

if __name__ == "__main__":
    load_modules()
