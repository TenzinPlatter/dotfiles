#!/usr/bin/env zsh

# Load modules from ~/.config/zsh/modules.yaml using Python YAML parser
load_modules() {
    local python_script="${ZDOTDIR:-$HOME/.config/zsh}/load-modules.py"
    local profile_flag=""

    # Check for --profile flag
    if [[ "$1" == "--profile" ]]; then
        profile_flag="--profile"
    fi

    if [[ ! -f "$python_script" ]]; then
        echo "Error: Python module loader not found at $python_script" >&2
        return 1
    fi

    if [[ -n "$profile_flag" ]]; then
        # Profile mode: capture source commands and time them
        local -a module_files
        local -a module_times
        local line

        while IFS= read -r line; do
            if [[ "$line" == source* ]]; then
                local file_path="${line#source }"
                file_path="${file_path#\'}"
                file_path="${file_path%\'}"

                local start_time=$(($(date +%s%N)/1000000))
                eval "$line"
                local end_time=$(($(date +%s%N)/1000000))
                local elapsed=$((end_time - start_time))

                module_files+=("$file_path")
                module_times+=("$elapsed")
            fi
        done < <(python3 "$python_script")

        # Display profiling table
        echo "\n╔════════════════════════════════════════════════════════════════════════════════╗"
        echo "║                          Module Load Profiling Results                        ║"
        echo "╠════════════════════════════════════════════════════════════════════════════════╣"
        printf "║ %-70s %8s ║\n" "Module" "Time (ms)"
        echo "╠════════════════════════════════════════════════════════════════════════════════╣"

        local total_time=0
        for i in {1..$#module_files}; do
            local file="${module_files[$i]}"
            local time="${module_times[$i]}"
            total_time=$((total_time + time))

            # Truncate long file paths
            local display_file="$file"
            if [[ ${#display_file} -gt 70 ]]; then
                display_file="...${display_file: -67}"
            fi

            printf "║ %-70s %8d ║\n" "$display_file" "$time"
        done

        echo "╠════════════════════════════════════════════════════════════════════════════════╣"
        printf "║ %-70s %8d ║\n" "TOTAL" "$total_time"
        echo "╚════════════════════════════════════════════════════════════════════════════════╝\n"
    else
        # Normal mode: just execute
        eval "$(python3 "$python_script")"
    fi
}

load_modules "$@"
