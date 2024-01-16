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

# Function to remove directories
remove_directory() {
    local dir_to_remove="$1"
    if [ -d "$HOME/.config/$dir_to_remove" ]; then
        rm -rf "$HOME/.config/$dir_to_remove"
        echo -e "${GREEN}Configuration directory for $dir_to_remove removed.${NC}"
    fi
}

for app in "${apps_to_remove[@]}"; do
    echo -e "Checking and removing $app..."
    # Remove related directories in ~/.config regardless of installation status
    remove_directory "$app"

    if command -v "$app" &> /dev/null; then
        sudo apt-get remove --purge "$app" -y
        echo -e "${GREEN}$app was successfully removed.${NC}"
    else
        echo -e "$app is not installed."
    fi
done

# Explicitly remove directories for hexchat, evolution, and caja
remove_directory "hexchat"
remove_directory "evolution"
remove_directory "caja"

sudo apt-get autoremove -y
