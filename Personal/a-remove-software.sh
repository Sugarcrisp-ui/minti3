#!/bin/bash

apps_to_remove=(
  "caja"
  "evolution"  
  "hexchat"
  "hypnotix"
  "libreoffice-base"
  "libreoffice-impress"
  "libreoffice-math"
  "rhythmbox"
  "thunderbird"
  "transmission"
)

for app in "${apps_to_remove[@]}"; do
    echo "Checking and removing $app..."
    # Remove related directories in ~/.config regardless of installation status
    rm -rf "$HOME/.config/$app"
    if command -v "$app" &> /dev/null; then
        echo "Removing $app..."
        sudo apt-get remove --purge "$app" -y
    else
        echo "$app is not installed."
    fi
done

sudo apt-get autoremove -y
