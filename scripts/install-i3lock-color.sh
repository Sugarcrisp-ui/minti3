#!/bin/bash

USER=$(whoami)
USER_HOME="/home/$USER"

# Install dependencies
sudo apt-get install -y \
    autoconf \
    automake \
    gcc \
    make \
    pkg-config \
    libx11-dev \
    libxext-dev \
    libxrandr-dev \
    libxpm-dev \
    libxcb1-dev \
    libxcb-dpms0-dev \
    libxcb-image0-dev \
    libxcb-util0-dev \
    libxcb-xrm-dev \
    libxcb-composite0-dev \
    libxcb-xinerama0-dev \
    libxcb-randr0-dev \
    libx11-xcb-dev \
    libxcb-xkb-dev \
    libjpeg-dev \
    libpam0g-dev \
    libcairo2-dev \
    libfontconfig1-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libgif-dev \
    libev-dev

# Clone i3lock-color repository
echo "Cloning i3lock-color repository..."
if [ -d "$USER_HOME/i3lock-color" ]; then
    echo "i3lock-color repository already exists at $USER_HOME/i3lock-color, updating..."
    cd "$USER_HOME/i3lock-color"
    git pull
else
    git clone https://github.com/Raymo111/i3lock-color.git "$USER_HOME/i3lock-color"
fi

# Clean up stale build directories
echo "Cleaning up stale build directories..."
cd "$USER_HOME/i3lock-color"
rm -rf build
mkdir build
cd build

# Build and install
autoreconf -fi ..
../configure
make
sudo make install

# Verify installation
i3lock --version

echo "i3lock-color installation complete."
