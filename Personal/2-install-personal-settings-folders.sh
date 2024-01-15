#!/bin/bash
set -e

# Source and destination directories
source_dir=~/minti3/personal-settings
destination_dir=~/

# Run chmod +x on *.sh files in .bin-personal
chmod +x $source_dir/.bin-personal/*.sh

# Run chmod +x on all .sh files in .config/polybar and .local/bin/
chmod +x $source_dir/.config/polybar/*.sh
chmod +x $source_dir/.local/bin/*.sh

# Run chmod +x on autotiling in .local directory
chmod +x $source_dir/.local/bin/autotiling

# Run chmod +x on .desktop files in .local/share/applications
chmod +x $source_dir/.local/share/applications/*.desktop

# Copy directories with overwriting existing files
cp -rf $source_dir/.bin-personal/ $destination_dir
cp -rf $source_dir/.config/ $destination_dir
cp -rf $source_dir/.local/ $destination_dir

# Copy specific files with overwriting existing files
cp -f $source_dir/.gtkrc-2.0.mine $destination_dir
cp -f $source_dir/bash_aliases $destination_dir

# Copy JPEG files to Pictures directory with overwriting existing files
cp -f $source_dir/*.jpg ~/Pictures/
