#!/bin/bash

# Install dependencies for i3lock-color
echo "Installing dependencies..."
apt-get install -y autoconf automake pkg-config libx11-dev libxext-dev libxrandr-dev libxpm-dev libxcb1-dev libxcb-dpms0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libjpeg-dev libpam0g-dev libcairo2-dev libxkbcommon-dev libxkbcommon-x11-dev libgif-dev
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies for i3lock-color. Exiting."
    exit 1
fi

# Clone or update i3lock-color repository
if [ ! -d "/home/brett/i3lock-color" ]; then
    echo "Cloning i3lock-color repository..."
    git clone https://github.com/Raymo111/i3lock-color.git /home/brett/i3lock-color
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3lock-color repository. Exiting."
        exit 1
    fi
else
    echo "i3lock-color repository already exists at /home/brett/i3lock-color, updating..."
    cd /home/brett/i3lock-color
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update i3lock-color repository. Exiting."
        exit 1
    fi
fi

# Build and install i3lock-color
cd /home/brett/i3lock-color
autoreconf -i
mkdir -p build && cd build
../configure --prefix=/usr/local
make
make install

# Verify installation
i3lock-color --version

echo "i3lock-color installation complete."
