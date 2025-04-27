#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi
sudo apt-get install -y \
    bc \
    imagemagick \
    libjpeg-turbo-progs \
    x11-xserver-utils \
    libpam0g-dev \
    libxrandr-dev \
    libev-dev \
    libxcb-composite0 \
    libxcb-composite0-dev \
    libxcb-xinerama0 \
    libxcb-randr0 \
    libxcb-util-dev \
    libxcb-image0 \
    libxcb-image0-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    libcairo2-dev \
    libfontconfig1-dev
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies. Exiting."
    exit 1
fi

# Clone Betterlockscreen repository
echo "Cloning Betterlockscreen repository..."
if [ -d "/home/$(whoami)/betterlockscreen" ]; then
    echo "Betterlockscreen repository already exists, updating..."
    cd /home/$(whoami)/betterlockscreen
    git pull
else
    git clone https://github.com/betterlockscreen/betterlockscreen.git /home/$(whoami)/betterlockscreen
fi
if [ $? -ne 0 ]; then
    echo "Error: Failed to clone or update Betterlockscreen repository. Exiting."
    exit 1
fi

# Install Betterlockscreen
echo "Installing Betterlockscreen..."
cd /home/$(whoami)/betterlockscreen
sudo make install
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Betterlockscreen. Exiting."
    exit 1
fi

# Verify installation
echo "Verifying Betterlockscreen installation..."
betterlockscreen --version
if [ $? -ne 0 ]; then
    echo "Error: Betterlockscreen not installed correctly. Exiting."
    exit 1
fi

echo "Betterlockscreen installation complete."
