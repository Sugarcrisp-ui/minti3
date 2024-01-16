#!/bin/bash
set -e

# Install pip
sudo apt install python3-pip

# Install autotiling using pip
pip3 install autotiling --user

# Create user-level bin directory if it doesn't exist
mkdir -p $HOME/.local/bin

# Run chmod +x on autotiling in user-level bin directory
chmod +x $HOME/.local/bin/autotiling

# Output a message
echo "autotiling has been installed successfully!"
