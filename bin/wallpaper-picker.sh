#!/bin/bash

# Store the selected file from yazi
selected=$(yazi --chooser-file=/dev/stdout ~/wallpapers)

# If a file was selected, set it as wallpaper with swww
if [ -n "$selected" ]; then
    swww img "$selected"
fi
