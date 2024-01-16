#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Directories to remove in ~/.config
for dir in hexchat hypnotix libreoffice-base libreoffice-impress libreoffice-math rhythmbox thunderbird transmission; do
    dir_path="$HOME/.config/$dir"
    if [ -d "$dir_path" ]; then
        rm -rf "$dir_path"
        echo -e "${GREEN}Configuration directory for $dir removed.${NC}"
    else
        echo -e "Configuration directory for $dir not found."
    fi
done

# Explicitly remove directories for hexchat, evolution, and caja
for dir in hexchat evolution caja; do
    dir_path="$HOME/.config/$dir"
    if [ -d "$dir_path" ]; then
        rm -rf "$dir_path"
        echo -e "${GREEN}Configuration directory for $dir removed.${NC}"
    else
        echo -e "Configuration directory for $dir not found."
    fi
done

# Remove installed applications
sudo apt-get remove --purge hexchat hypnotix libreoffice-base libreoffice-impress libreoffice-math rhythmbox thunderbird transmission -y
sudo apt-get autoremove -y
