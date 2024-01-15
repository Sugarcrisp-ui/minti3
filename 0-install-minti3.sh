#!/bin/bash

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
sudo chmod +x *.sh

# List of install scripts in corrected numerical order
install_scripts=(
    a-remove-software.sh
    b-install-i3.sh
    c-install-personal-settings-folders.sh
    d-install-root-settings.sh
    e-gaps-install.sh
    f-install-core-software.sh
    g-insync.sh
    h-i3lock-fansy.sh
    i-laptop.sh
    j-fontawesome.sh
    k-install-picom.sh
    l-discord.sh
    m-vscode.sh
    n-realvnc.sh
    o-install-personal-settings-bookmarks.sh
    p-cryptomator-settings-for-thunar.sh
    q-install-settings-autoconnect-to-bluetooth-headset.sh
    r-software-flatpak.sh
    s-installing-fonts.sh
    t-autotiling.sh
    u-expressvpn.sh
)

# Install scripts without user interaction
for script in "${install_scripts[@]}"; do
    sudo ./$script
done

# Display completion message
echo "Mint i3 Install Complete"
