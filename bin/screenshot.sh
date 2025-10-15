#!/usr/bin/env bash

# Create Screenshots directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

# Generate filename with date and time (e.g., screenshot_2025-10-15_14-30-45.png)
FILENAME=~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

# Take screenshot and open in satty with output filename
grim -g "$(slurp)" - | satty -f - --output-filename "$FILENAME"
