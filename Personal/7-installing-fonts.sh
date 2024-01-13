#!/bin/bash

# List of fonts to install
fonts_to_install=(
    fonts-dejavu
    fonts-font-awesome
    fonts-inconsolata
    fonts-liberation
    fonts-noto
    fonts-roboto
    fonts-ubuntu
    fonts-ubuntu-console
    fonts-ubuntu-title
    ttf-mscorefonts-installer
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
