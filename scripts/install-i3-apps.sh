#!/bin/bash

echo "Updating package lists..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi

echo "Installing standard apt packages..."
sudo apt-get install -y \
    feh \
    geany \
    qbittorrent \
    thunar \
    xfce4-settings \
    xfce4-power-manager \
    xfce4-panel \
    network-manager-gnome \
    network-manager-openvpn-gnome
if [ $? -ne 0 ]; then
    echo "Error: Failed to install standard packages. Exiting."
    exit 1
fi

echo "Installing ProtonVPN..."
sudo apt-get install -y curl gnupg
if [ $? -ne 0 ]; then
    echo "Error: Failed to install curl and gnupg. Exiting."
    exit 1
fi
if [ ! -f /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg ]; then
    curl -sSL https://repo.protonvpn.com/debian/public_key.asc | sudo gpg --dearmor -o /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download or process ProtonVPN key. Exiting."
        exit 1
    fi
fi
echo "deb [signed-by=/usr/share/keyrings/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" | sudo tee /etc/apt/sources.list.d/protonvpn.list
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists with ProtonVPN repository. Exiting."
    exit 1
fi
sudo apt-get install -y protonvpn
if [ $? -ne 0 ]; then
    echo "Error: Failed to install ProtonVPN. Exiting."
    exit 1
fi

echo "Installing Bitwarden via Flatpak..."
sudo flatpak install flathub com.bitwarden.desktop -y
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Bitwarden Flatpak. Exiting."
    exit 1
fi

echo "i3 apps installation complete."
