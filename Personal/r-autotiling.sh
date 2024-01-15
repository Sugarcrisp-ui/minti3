#!/bin/bash
set -e

# Install pip
sudo apt update
sudo apt install python3-pip

# Install autotiling using pip
pip3 install autotiling

# Run chmod +x on autotiling in .local directory
chmod +x $source_dir/.local/bin/autotiling

# Output a message
echo "autotiling has been installed successfully!"
