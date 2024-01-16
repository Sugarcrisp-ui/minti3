#!/bin/bash

set -e

# Function to display text in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Check if running with sudo
if [ "$EUID" -eq 0 ]; then
    # If running with sudo, restart the script without sudo
    echo "Running with sudo. Restarting without sudo..."
    sudo -u "$SUDO_USER" bash "$0" "$@"
    exit $?
fi

# Install i3 window manager
echo -e "\e[32mInstalling i3...\e[0m"
sudo apt install i3 -y

# Install Polybar
echo -e "\e[32mInstalling Polybar...\e[0m"
sudo apt install polybar -y

# Create Polybar scripts directory
mkdir -p $HOME/.config/polybar/scripts

# Transfer Polybar scripts
cp $HOME/minti3/personal-settings/.config/polybar/scripts/* $HOME/.config/polybar/scripts/

# Make Polybar scripts executable
chmod +x $HOME/.config/polybar/scripts/*.sh

print_green "i3 and Polybar have been successfully installed."
