#!/bin/bash

# Smart move script for niri
# Moves focus/window across monitors when at workspace edge

direction=$1
mode=${2:-focus}  # focus or move

case $direction in
    left|h)
        if [[ $mode == "move" ]]; then
            niri msg action move-column-left-or-to-monitor-left
        else
            niri msg action focus-column-or-monitor-left
        fi
        ;;
    right|l)
        if [[ $mode == "move" ]]; then
            niri msg action move-column-right-or-to-monitor-right
        else
            niri msg action focus-column-or-monitor-right
        fi
        ;;
    *)
        echo "Usage: $0 {left|right|h|l} [focus|move]"
        exit 1
        ;;
esac
