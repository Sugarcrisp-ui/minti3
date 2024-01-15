#!/bin/bash

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
sudo chmod +x *.sh

# List of install scripts in corrected numerical order
install_scripts=(
    "1-remove-software.sh"
    "2-install-i3.sh"
    "3-install-personal-settings-folders.sh"
    "4-install-root-settings.sh"
#    "5-gaps-install.sh"
    "6-install-core-software.sh"
    "7-insync.sh"
    "8-i3lock-fansy.sh"
    "9-laptop.sh"
    "10-fontawesome.sh"
    "11-install-picom.sh"
    "12-discord.sh"
    "13-vscode.sh"
    "14-realvnc.sh"
    "15-install-personal-settings-bookmarks.sh"
    "16-cryptomator-settings-for-thunar.sh"
    "17-install-settings-autoconnect-to-bluetooth-headset.sh"
    "18-software-flatpak.sh"
    "19-installing-fonts.sh"
    "20-autotiling.sh"
"21-expressvpn.sh"
)

# Install scripts without user interaction
for script in "${install_scripts[@]}"; do
    sudo ./$script
done

# Display completion message
echo "Mint i3 Install Complete"
