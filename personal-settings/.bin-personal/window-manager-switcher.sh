#!/bin/bash

# Check which display manager is currently running
CURRENT_DM=$(cat /etc/X11/default-display-manager)

echo "Current Display Manager: $CURRENT_DM"

# Switch from SDDM to LightDM
if [[ $CURRENT_DM == *"sddm"* ]]; then
    echo "Switching from SDDM to LightDM..."
    read -p "Do you want to proceed? [Y/n] " choice
    choice=${choice:-Y}
    if [[ $choice == [Yy]* ]]; then
        sudo apt install lightdm
        sudo dpkg-reconfigure sddm
        sudo systemctl disable sddm
        sudo systemctl enable lightdm.service --force
        echo "Switched to LightDM. Please reboot your system for the changes to take effect."
    fi
# Switch from LightDM to SDDM
elif [[ $CURRENT_DM == *"lightdm"* ]]; then
    echo "Switching from LightDM to SDDM..."
    read -p "Do you want to proceed? [Y/n] " choice
    choice=${choice:-Y}
    if [[ $choice == [Yy]* ]]; then
        sudo apt install sddm
        sudo dpkg-reconfigure lightdm
        sudo systemctl disable lightdm
        sudo systemctl enable sddm.service --force
        echo "Switched to SDDM. Please reboot your system for the changes to take effect."
    fi
else
    echo "Neither SDDM nor LightDM is currently running."
fi
