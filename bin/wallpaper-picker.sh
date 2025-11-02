#!/usr/bin/env bash

# Store the selected file from yazi
selected=$(yazi --chooser-file=/dev/stdout ~/wallpapers)

# If a file was selected, set it as wallpaper with swww
if [ -n "$selected" ]; then
    dms ipc call wallpaper set "$selected"
    echo "$selected" > ~/.cache/current_wallpaper
fi
