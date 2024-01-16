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
        sudo apt install -y "$font"
        echo "Installed: $font"
    fi
done

# Download and install Comic Sans MS directly
comic_sans_url="https://www.dafontfree.io/download/comic-sans-ms/"
comic_sans_file="/tmp/comic-sans-ms.zip"
comic_sans_install_dir="/usr/share/fonts/truetype/"

if [ ! -f "$comic_sans_install_dir/COMIC.TTF" ]; then
    echo "Downloading Comic Sans MS..."
    wget "$comic_sans_url" -O "$comic_sans_file"
    
    echo "Installing Comic Sans MS..."
    sudo unzip -o "$comic_sans_file" -d "$comic_sans_install_dir"
    
    # Additional steps to refresh font cache may be required
    sudo fc-cache -f -v
fi
