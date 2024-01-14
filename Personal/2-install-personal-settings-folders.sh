#!/bin/bash
set -e

# Source and destination directories
source_dir=~/minti3/personal-settings
destination_dir=~/

# Copy directories
cp -r $source_dir/.bin-personal/ $destination_dir
cp -r $source_dir/.config/ $destination_dir
cp -r $source_dir/.local/ $destination_dir

# Copy specific files
cp $source_dir/.gtkrc-2.0.mine $destination_dir
cp $source_dir/bash_aliases $destination_dir

# Copy JPEG files to Pictures directory
cp $source_dir/*.jpg ~/Pictures/
