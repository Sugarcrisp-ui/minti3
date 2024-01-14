#!/bin/bash

# Set your preferred options for betterlockscreen and i3lock-color here
# For example:
# BLUR=10
# DIM=50
COLOR="000000"

# Change to your preferred wallpaper directory
WALLPAPER_DIR="$HOME/Pictures/"

# Lock screen with betterlockscreen and i3lock-color
betterlockscreen -u "$WALLPAPER_DIR/$(ls $WALLPAPER_DIR | shuf -n1)" -l dimblur "$DIM" "$BLUR" "$COLOR"