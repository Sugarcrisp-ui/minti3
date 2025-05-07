#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-i3-apps-$TIMESTAMP.txt"
LATEST_LOG="$LOG_DIR/install-i3-apps-output.txt"

# Redirect output to timestamped and latest log files
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE" "$LATEST_LOG") 2>&1
echo "Logging output to $OUTPUT_FILE and $LATEST_LOG"

# Preconfigure sddm as default display manager
echo "Preconfiguring sddm as default display manager..."
if [ -f "/etc/X11/default-display-manager" ]; then
    echo "/usr/sbin/sddm" | sudo tee /etc/X11/default-display-manager >/dev/null
    if [ $? -eq 0 ]; then
        echo "Set sddm as default display manager in /etc/X11/default-display-manager."
    else
        echo "Warning: Failed to set sddm as default display manager. Continuing."
    fi
else
    echo "Warning: /etc/X11/default-display-manager not found. Continuing."
fi

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
	brave-browser
    feh
    geany
    qbittorrent
    thunar
    xfce4-settings
    xfce4-power-manager
    xfce4-panel
    network-manager-gnome
    network-manager-openvpn-gnome
    arandr
    audacity
    fonts-liberation-sans-narrow
    fonts-linuxlibertine
    fonts-noto-extra
    fonts-noto-ui-core
    fonts-sil-gentium
    fonts-sil-gentium-basic
    gdm3
    geoclue-2.0
    ubuntu-docs
    ubuntu-session
    ubuntu-wallpapers
    ubuntu-wallpapers-noble
    vlc
    warp-terminal
    whoopsie
    xdotool
    yaru-theme-gnome-shell
    zim
)
for pkg in "${packages[@]}"; do
    if [ "$pkg" = "brave-browser" ]; then
        echo "Setting up Brave Browser repository..."
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        if [ $? -ne 0 ]; then
            echo "Error: Failed to download Brave Browser keyring. Exiting."
            exit 1
        fi
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        if [ $? -ne 0 ]; then
            echo "Error: Failed to set up Brave Browser repository. Exiting."
            exit 1
        fi
        sudo apt-get update
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update apt after adding Brave repository. Exiting."
            exit 1
        fi
        sudo apt-get install -y brave-browser
    fi
            
        elif [ "$pkg" = "warp-terminal" ]; then
            sudo apt-get install -y wget gpg
            wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
            sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
            sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
            rm warpdotdev.gpg
            sudo apt-get update
            sudo apt-get install -y warp-terminal
        elif [ "$pkg" = "gdm3" ]; then
            echo "gdm3 shared/default-x-display-manager select sddm" | sudo debconf-set-selections
            sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
        else
            sudo apt-get install -y "$pkg"
        fi
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Ensure SDDM remains the default display manager
echo "Ensuring SDDM is the default display manager..."
if [ -f "/etc/X11/default-display-manager" ]; then
    echo "/usr/sbin/sddm" | sudo tee /etc/X11/default-display-manager >/dev/null
    if [ $? -eq 0 ]; then
        echo "Confirmed sddm as default display manager."
    else
        echo "Warning: Failed to confirm sddm as default display manager."
    fi
fi

echo "i3-apps installation complete."
