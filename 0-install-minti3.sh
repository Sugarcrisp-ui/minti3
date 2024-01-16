#!/bin/bash

# Function to display text in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
sudo chmod +x *.sh

# List of install scripts in corrected alphabetical order
install_scripts=(
    0-install-minti3.sh
    a-remove-software.sh
    b-install-i3.sh
    c-install-personal-settings-folders.sh
    d-install-root-settings.sh
    e-install-core-software.sh
    f-insync.sh
    g-i3lock-fansy.sh
    h-laptop.sh
    i-fontawesome.sh
    j-install-picom.sh
    k-vscode.sh
    l-realvnc.sh
    m-install-personal-settings-bookmarks.sh
    n-cryptomator-settings-for-thunar.sh
    o-install-settings-autoconnect-to-bluetooth-headset.sh
    p-software-flatpak.sh
    q-installing-fonts.sh
    r-autotiling.sh
    s-discord.sh
    t-expressvpn.sh
    # u-gaps-install.sh (commented out)
)

# Prompt user for password once
sudo echo "Prompting for password..."

# Install scripts without user confirmation
for script in "${install_scripts[@]}"; do
    print_green "Running $script"
    if [ "$script" = "0-install-minti3.sh" ]; then
        # Run Polybar installation without sudo to maintain user's home directory
        ./$script
        # Create Polybar scripts directory
        mkdir -p $HOME/.config/polybar/scripts
        # Make Polybar scripts executable
        chmod +x $HOME/.config/polybar/scripts/*.sh
        print_green "Polybar scripts have been made executable."
    else
        # Run other scripts with sudo
        sudo ./$script
    fi
    if [ $? -ne 0 ]; then
        echo -e "\e[31mError executing $script. Exiting...\e[0m"
        exit 1
    fi
done

# Display completion message
print_green "Mint i3 Install Complete"
