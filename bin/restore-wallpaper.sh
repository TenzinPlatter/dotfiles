#!/usr/bin/env bash

# Restore the last wallpaper on startup
if [ -f ~/.cache/current_wallpaper ]; then
    wallpaper=$(cat ~/.cache/current_wallpaper)
    swww-daemon &
    sleep 0.5
    if [ -f "$wallpaper" ]; then
        swww img "$wallpaper" --resize crop
    else
        swww img "f1-redbull.jpeg"
    fi
fi
