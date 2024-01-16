#!/bin/bash
set -e

# Copy contents of directories with overwriting existing files and preserving ownership
mkdir -p "$HOME"/.bin-personal
cp -r "$HOME"/minti3/personal-settings/.bin-personal/* "$HOME"/.bin-personal
chmod +x "$HOME"/.bin-personal/*.sh 2>/dev/null || true  # Ignore errors if no files match

mkdir -p "$HOME"/.config
cp -r "$HOME"/minti3/personal-settings/.config/* "$HOME"/.config
chmod +x "$HOME"/polybar/scripts/*.sh 2>/dev/null || true  # Ignore errors if no files match
chmod +x "$HOME"/polybar/scripts/*.py 2>/dev/null || true  # Ignore errors if no files match

mkdir -p "$HOME"/.local
cp -r "$HOME"/minti3/personal-settings/.local/* "$HOME"/.local

# Copy specific files with overwriting existing files and preserving ownership
cp "$HOME"/minti3/personal-settings/.gtkrc-2.0.mine "$HOME"
cp "$HOME"/minti3/personal-settings/.bash_aliases "$HOME"

# Copy JPEG files to Pictures directory with overwriting existing files
mkdir -p "$HOME"/Pictures
cp "$HOME"/minti3/personal-settings/*.jpg "$HOME"/Pictures

# Remove directories (if needed) and remove executable permissions
if [ -d "$HOME"/.config/caja ]; then
    rm -r "$HOME"/.config/caja
fi

if [ -d "$HOME"/.config/evolution ]; then
    rm -r "$HOME"/.config/evolution
fi

if [ -d "$HOME"/.config/hexchat ]; then
    rm -r "$HOME"/.config/hexchat
fi
