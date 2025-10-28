#!/usr/bin/env bash

# Restore the last wallpaper on startup
if [ -f ~/.cache/current_wallpaper ]; then
    wallpaper=$(cat ~/.cache/current_wallpaper)
    swww-daemon &
    sleep 0.5
    if [ -f "$wallpaper" ]; then
        dms ipc call wallpaper set "$selected"
    else
        dms ipc call wallpaper set "~/wallpapers/Tokyo Night/street.gif"
    fi
fi
