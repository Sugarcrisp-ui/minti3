#!/bin/bash

# Clone or update i3-logout repository
if [ -d "/home/brett/i3-logout/.git" ]; then
    echo "i3-logout repository already exists at /home/brett/i3-logout, updating..."
    cd /home/brett/i3-logout
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update i3-logout repository. Exiting."
        exit 1
    fi
else
    echo "Cloning i3-logout repository..."
    git clone git@github.com:Sugarcrisp-ui/i3-logout.git /home/brett/i3-logout
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3-logout repository. Exiting."
        exit 1
    fi
fi

# Build and install i3-logout
echo "Building and installing i3-logout..."
cd /home/brett/i3-logout
make
if [ $? -ne 0 ]; then
    echo "Error: Failed to build i3-logout. Exiting."
    exit 1
fi

sudo make install
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3-logout. Exiting."
    exit 1
fi

echo "i3-logout installation complete."
