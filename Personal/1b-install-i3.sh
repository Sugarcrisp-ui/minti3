#!/bin/bash

set -e

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run with sudo."
    exit
fi

# Update package list
apt update

# Install i3 window manager
apt install i3 -y

# Install Polybar
apt install polybar -y

echo "i3 and Polybar have been successfully installed."
