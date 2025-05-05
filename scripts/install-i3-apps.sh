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
    bat
    brave-browser
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
    whoopsie
    xdotool
    yaru-theme-gnome-shell
    zim
)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        if [ "$pkg" = "brave-browser" ]; then
            sudo apt-get install -y apt-transport-https curl
            sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt-get update
            sudo apt-get install -y brave-browser
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

# Install warp-terminal via Flatpak
echo "Installing warp-terminal via Flatpak..."
if ! command -v flatpak >/dev/null; then
    echo "Installing Flatpak..."
    sudo apt-get install -y flatpak
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install Flatpak. Continuing."
    fi
fi
if ! flatpak remote-list | grep -q flathub; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add Flathub repository. Continuing."
    fi
fi
if ! flatpak list | grep -q com.warp.Warp; then
    echo "Installing com.warp.Warp..."
    flatpak install -y flathub com.warp.Warp
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install warp-terminal via Flatpak. Continuing."
    fi
else
    echo "warp-terminal is already installed via Flatpak."
fi

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
