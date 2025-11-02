#!/usr/bin/env bash

# Create Screenshots directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

# Generate filename with date and time (e.g., screenshot_2025-10-15_14-30-45.png)
FILENAME=~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

# Take screenshot, copy original to clipboard, and open in satty
grim -g "$(slurp)" - | tee >(wl-copy --type image/png) | satty -f - --output-filename "$FILENAME"

# After satty closes, if the annotated file was saved, update clipboard with it
if [ -f "$FILENAME" ]; then
    wl-copy --type image/png < "$FILENAME"
fi
