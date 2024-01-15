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
echo -e "\e[32mInstalling i3...\e[0m"
echo "$PASSWORD" | sudo -S apt install i3 -y

# Install Polybar
echo -e "\e[32mInstalling Polybar...\e[0m"
echo "$PASSWORD" | sudo -S apt install polybar -y

# Make Polybar scripts executable
chmod +x ~/.config/polybar/scripts/*.sh

echo -e "\e[32mi3 and Polybar have been successfully installed.\e[0m"
