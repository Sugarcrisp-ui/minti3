#!/bin/bash

set -e

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
            echo "$package successfully installed."
        else
            echo "Error installing $package."
        fi
    else
        echo "$package is already installed."
    fi
done
