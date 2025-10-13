#!/usr/bin/env bash

current_wallpaper=$(cat ~/.cache/current_wallpaper)

# Fallback to default if current wallpaper is a gif
if [[ "$current_wallpaper" == *.gif ]]; then
    current_wallpaper="$HOME/.config/wallpapers/default.png"
fi

swaylock \
	--screenshots \
	--clock \
	--indicator \
	--indicator-radius 100 \
	--indicator-thickness 7 \
	--effect-blur 10x10 \
	--effect-vignette 0.5:0.5 \
	--ring-color bb00cc \
	--key-hl-color 880033 \
	--line-color 00000000 \
	--inside-color 00000088 \
	--separator-color 00000000 \
	--grace 2
