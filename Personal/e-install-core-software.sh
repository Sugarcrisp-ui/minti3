#!/bin/bash

set -e

# Define colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# List of packages to install.
list=(
    # Web Browsers
    chromium-browser
    
    # Multimedia
    celluloid
    ffmpeg
    simplescreenrecorder
    spotify-client
    vlc

    # Utilities
    baobab
    catfish
    copyq
    feh
    fish
    flatpak
    font-manager
    gpick
    imagemagick
    meld
    most
    paprefs
    pavucontrol
    pinta
    python3-pip
    # polybar
    qbittorrent
    qtbase5-dev 
    qtchooser 
    qt5-qmake 
    qtbase5-dev-tools
    rofi
    seahorse
    sshfs
    timeshift
    unzip
    webapp-manager
    wget
    xfce4-appfinder
    xfce4-notifyd
    xfce4-power-manager
    xfce4-screenshooter
    xfce4-settings
    xfce4-taskmanager
    xfce4-terminal
    zip

    # Documents and Text
    micro
    sublime-text
    sublime-merge
    
    # Communication

    # Others
    
    # Developer
)

# Check and install packages
for package in "${list[@]}"; do
    if ! dpkg -l | grep -q $package; then
        sudo apt-get install -y $package
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$package successfully installed.${NC}"
        else
            echo -e "${GREEN}Error installing $package.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}$package is already installed.${NC}"
    fi
done
