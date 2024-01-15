#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color

apps_to_remove=(
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
    echo -e "Checking and removing $app..."
    # Remove related directories in ~/.config regardless of installation status
    rm -rf "$HOME/.config/$app"
    if command -v "$app" &> /dev/null; then
        sudo apt-get remove --purge "$app" -y
        echo -e "${GREEN}$app was successfully removed.${NC}"
    else
        echo -e "$app is not installed."
    fi
done

sudo apt-get autoremove -y
