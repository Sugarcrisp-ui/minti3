#!/bin/bash

USER_HOME="/home/brett"

# Install dependencies
sudo apt install autoconf automake pkg-config libx11-dev libxext-dev libxrandr-dev libxpm-dev libxcb1-dev libxcb-dpms0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libjpeg-dev libpam0g-dev libcairo2-dev libxkbcommon-dev libxkbcommon-x11-dev libgif-dev -y

# Remove existing i3lock-color directory if it exists
if [ -d "$USER_HOME/i3lock-color" ]; then
    rm -rf "$USER_HOME/i3lock-color"
fi

# Clone i3lock-color repository
git clone https://github.com/Raymo111/i3lock-color.git "$USER_HOME/i3lock-color"
cd "$USER_HOME/i3lock-color"

# Build and install
autoreconf -fiv
./configure
make
sudo make install

# Rename binary to i3lock-color
sudo mv /usr/local/bin/i3lock /usr/local/bin/i3lock-color

# Verify installation
i3lock-color --version