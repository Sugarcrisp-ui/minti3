#!/bin/bash

# List of fonts to install
fonts_to_install=(
    ttf-mscorefonts-installer
    fonts-dejavu
    fonts-font-awesome
    fonts-inconsolata
    fonts-liberation
    fonts-noto
    fonts-roboto
    fonts-ubuntu
    fonts-ubuntu-console
    fonts-ubuntu-title
)

# Check and install fonts
for font in "${fonts_to_install[@]}"; do
    if fc-list | grep -q "$font"; then
        echo "$font is already installed."
    else
        sudo apt update
        sudo apt install -y "$font"
        echo "Installed: $font"
    fi
done

# Explicitly install Comic Sans MS from ttf-mscorefonts-installer
if ! fc-list | grep -q "Comic Sans MS"; then
    echo "Installing: Comic Sans MS"
    sudo apt install -y ttf-mscorefonts-installer
    # Additional steps to refresh font cache may be required
    sudo fc-cache -f -v
fi
