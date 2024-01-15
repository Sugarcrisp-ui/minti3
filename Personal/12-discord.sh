#!/bin/bash

set -e

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit
fi

# Update package list
sudo apt update

# Install i3 window manager
echo "Installing i3..."
echo "$PASSWORD" | sudo -S apt install i3 -y

# Install Polybar
echo "Installing Polybar..."
echo "$PASSWORD" | sudo -S apt install polybar -y

# Make Polybar scripts executable
chmod +x ~/.config/polybar/scripts/*.sh

echo "i3 and Polybar have been successfully installed."
