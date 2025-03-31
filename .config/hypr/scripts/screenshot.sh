#!/bin/bash

if [[ "$1" == "-c" ]]; then
	grim -g "$(slurp)" - | wl-copy
else
	grim -g "$(slurp)" -t png ~/screenshots/$(date +%Y-%m-%d_%H-%m-%s).png
fi
