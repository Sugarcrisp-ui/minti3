#!/bin/bash
set -e

# Source and destination directories with full paths
source_dir=/home/brett/minti3/personal-settings
destination_dir=/home/brett/

# Change directory to the source directory
cd "$source_dir"

# Run chmod +x on *.sh files in .bin-personal
chmod +x .bin-personal/*.sh

# Run chmod +x on all .sh files in .config/polybar
chmod +x .config/polybar/*.sh

# Run chmod +x on autotiling in .local directory
chmod +x .local/bin/autotiling

# Run chmod +x on .desktop files in .local/share/applications
chmod +x .local/share/applications/*.desktop

# Copy directories with overwriting existing files
cp -rf .bin-personal/ "$destination_dir"
cp -rf .config/ "$destination_dir"
cp -rf .local/ "$destination_dir"

# Copy specific files with overwriting existing files
cp -f .gtkrc-2.0.mine "$destination_dir"
cp -f .bash_aliases "$destination_dir"

# Copy JPEG files to Pictures directory with overwriting existing files
cp -f *.jpg "$destination_dir/Pictures/"
