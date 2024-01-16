#!/bin/bash

# Function to display text in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
chmod +x *.sh

# List of root-level install scripts in corrected alphabetical order
root_scripts=(
    a-remove-software.sh
    b-install-i3.sh
    d-install-root-settings.sh
    e-install-core-software.sh
    f-insync.sh
    g-i3lock-fansy.sh
    h-laptop.sh
    i-fontawesome.sh
    j-install-picom.sh
    k-vscode.sh
    l-realvnc.sh
    p-software-flatpak.sh
    q-installing-fonts.sh
    r-autotiling.sh
    s-discord.sh
    t-expressvpn.sh
    # u-gaps-install.sh (commented out)
)

# List of user-level install scripts in corrected alphabetical order
user_scripts=(
    c-install-personal-settings-folders.sh
    m-install-personal-settings-bookmarks.sh
    n-cryptomator-settings-for-thunar.sh
    o-install-settings-autoconnect-to-bluetooth-headset.sh
)

# Prompt user for password once
echo "Prompting for password..."

# Install root-level scripts with user confirmation
for script in "${root_scripts[@]}"; do
    print_green "Running $script as root"
    sudo ./"$script"
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError executing $script. Exiting...\e[0m"
        exit 1
    fi
done

# Install user-level scripts without user confirmation
for script in "${user_scripts[@]}"; do
    print_green "Running $script as user"
    ./"$script"
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError executing $script. Exiting...\e[0m"
        exit 1
    fi
done

# Display completion message
print_green "Mint i3 Install Complete"
