#!/bin/bash
grim -g "$(slurp)" - | satty -f - --filename ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
