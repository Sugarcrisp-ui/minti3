#!/bin/bash

set -e

# Function to display text in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Install i3 window manager and Polybar
echo -e "\e[32mInstalling i3 and Polybar...\e[0m"
sudo apt install i3 polybar -y

# Create Polybar scripts directory
mkdir -p $HOME/.config/polybar/scripts

# Transfer Polybar scripts
cp $HOME/minti3/personal-settings/.config/polybar/scripts/* $HOME/.config/polybar/scripts/

# Make Polybar scripts executable
chmod +x $HOME/.config/polybar/scripts/*.sh

print_green "i3 and Polybar have been successfully installed."
