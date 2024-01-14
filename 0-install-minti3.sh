#!/bin/bash

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
chmod +x *.sh

sudo apt update

# List of install scripts in numerical order
install_scripts=(
    "1-remove-software.sh"
    "2-gaps-install.sh"
    "3-install-core-software.sh"
    "4-insync.sh"
    "5-i3lock-fansy.sh"
    "6-software-flatpak.sh"
    "7-installing-fonts.sh"
    "8-fontawesome.sh"
    "9-install-picom.sh"
    "10-discord.sh"
    "11-vscode.sh"
    "12-realvnc.sh"
    "13-install-personal-settings-bookmarks.sh"
    "14-cryptomator-settings-for-thunar.sh"
    "15-install-settings-autoconnect-to-bluetooth-headset.sh"
    "16-install-personal-settings-folders.sh"
    "17-laptop.sh"
    "18-expressvpn.sh"
)

# Install scripts based on user choice
for script in "${install_scripts[@]}"; do
    read -p "Run $script? (y/n): " choice
    if [ "$choice" == "y" ]; then
        ./$script
    else
        echo "Skipping $script"
    fi
done

# Ask to restart the system
read -p "Installation complete. Restart now? (y/n): " choice
if [ "$choice" == "y" ]; then
    sudo reboot
fi
