#!/bin/bash

set -e

# Add flathub remote if not exists
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Define flatpak applications
flatpaks=(
    "net.nokyan.Resources"
    "com.bitwarden.desktop"
    "com.authy.Authy"
    "org.cryptomator.Cryptomator"
    "io.github.shiftey.Desktop"
    "net.cozic.joplin_desktop"
)

# Install or check and echo
for app in "${flatpaks[@]}"; do
    if flatpak list | grep -q "$app"; then
        echo "$app is already installed."
    else
        flatpak install --noninteractive --assumeyes flathub "$app" >/dev/null 2>&1
    fi
done

echo "Flatpak installation completed."
