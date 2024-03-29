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

# Download Comic Sans MS directly
comic_sans_url="https://www.dafontfree.io/download/comic-sans-ms/?wpdmdl=71924&refresh=65a56a4b320751705339467&ind=1612711028804&filename=comic-sans-ms-font-family.zip"
comic_sans_file="/tmp/comic-sans-ms.zip"
comic_sans_install_dir="/usr/share/fonts/truetype/"

# Step 1: Download Comic Sans MS ZIP file using wget
wget -O "$comic_sans_file" "$comic_sans_url"

# Step 2: Extract the ZIP file
unzip -j "$comic_sans_file" -d "$comic_sans_install_dir"

# Step 3: Install fonts
for font in "${fonts_to_install[@]}"; do
    if fc-list | grep -q "$font"; then
        echo "$font is already installed."
    else
        sudo apt install -y "$font"
        echo "Installed: $font"
    fi
done

# Step 4: Install Comic Sans MS
sudo cp /tmp/COMIC.TTF "$comic_sans_install_dir"

# Additional steps to refresh font cache
sudo fc-cache -f -v

# Cleanup: Remove temporary ZIP file
rm "$comic_sans_file"
