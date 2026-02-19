#!/usr/bin/env bash

# Create Screenshots directory if it doesn't exist
mkdir -p ~/Pictures/Screenshots

# Generate filename with date and time (e.g., screenshot_2025-10-15_14-30-45.png)
FILENAME=~/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png
TMPFILE=$(mktemp --suffix=.png)

# Take screenshot to temp file, then open in satty for annotation
grim -g "$(slurp)" "$TMPFILE"
satty -f "$TMPFILE" --output-filename "$FILENAME"

# After satty closes, copy annotated file if saved, otherwise copy original
if [ -f "$FILENAME" ]; then
    wl-copy --type image/png < "$FILENAME"
else
    wl-copy --type image/png < "$TMPFILE"
fi

rm -f "$TMPFILE"
