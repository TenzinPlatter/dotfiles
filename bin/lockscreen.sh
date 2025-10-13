#!/usr/bin/env bash

current_wallpaper=$(cat ~/.cache/current_wallpaper)

# Fallback to default if current wallpaper is a gif
if [[ "$current_wallpaper" == *.gif ]]; then
    current_wallpaper="$HOME/.config/wallpapers/default.png"
fi

swaylock -i $current_wallpaper
