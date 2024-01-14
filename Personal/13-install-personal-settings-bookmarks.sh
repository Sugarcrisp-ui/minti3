#!/bin/bash

set -e

# Define relative source and destination paths
source_dir="../personal-settings/.config/gtk-3.0"
destination_dir="$HOME/.config/"

# Check if the source directory exists
if [ -d "$source_dir" ]; then
    # Copy the gtk-3.0 directory to the destination
    cp -r "$source_dir" "$destination_dir"
    echo "gtk-3.0 copied successfully to $destination_dir"
else
    echo "Error: Source directory not found: $source_dir"
fi
