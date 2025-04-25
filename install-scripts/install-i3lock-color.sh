#!/bin/bash

# Install dependencies for i3lock-color
echo "Installing dependencies..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi
sudo apt-get install -y autoconf automake pkg-config libx11-dev libxext-dev libxrandr-dev libxpm-dev libxcb1-dev libxcb-dpms0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libjpeg-dev libpam0g-dev libcairo2-dev libxkbcommon-dev libxkbcommon-x11-dev libgif-dev libev-dev libxcb-composite0-dev
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies for i3lock-color. Exiting."
    exit 1
fi

# Verify libev-dev installation
if ! dpkg -l | grep -q libev-dev; then
    echo "Error: libev-dev is not installed. Exiting."
    exit 1
fi

# Verify libxcb-composite0-dev installation
if ! dpkg -l | grep -q libxcb-composite0-dev; then
    echo "Error: libxcb-composite0-dev is not installed. Exiting."
    exit 1
fi

# Clone or update i3lock-color repository
if [ -d "/home/brett/i3lock-color/.git" ]; then
    echo "i3lock-color repository already exists at /home/brett/i3lock-color, updating..."
    cd /home/brett/i3lock-color
    sudo chown -R brett:brett /home/brett/i3lock-color
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update i3lock-color repository. Exiting."
        exit 1
    fi
else
    echo "Cloning i3lock-color repository..."
    git clone https://github.com/Raymo111/i3lock-color.git /home/brett/i3lock-color
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3lock-color repository. Exiting."
        exit 1
    fi
    sudo chown -R brett:brett /home/brett/i3lock-color
fi

# Clean up any stale build directories
echo "Cleaning up stale build directories..."
rm -rf /home/brett/i3lock-color/autom4te.cache /home/brett/i3lock-color/build
if [ $? -ne 0 ]; then
    echo "Error: Failed to clean up stale build directories. Attempting with sudo..."
    sudo rm -rf /home/brett/i3lock-color/autom4te.cache /home/brett/i3lock-color/build
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clean up stale build directories even with sudo. Exiting."
        exit 1
    fi
fi

# Build and install i3lock-color
cd /home/brett/i3lock-color
autoreconf -i
if [ $? -ne 0 ]; then
    echo "Error: Failed to run autoreconf for i3lock-color. Exiting."
    exit 1
fi
mkdir -p build && cd build
../configure --prefix=/usr/local
if [ $? -ne 0 ]; then
    echo "Error: Failed to configure i3lock-color. Check /home/brett/i3lock-color/build/config.log for details. Exiting."
    exit 1
fi
make
if [ $? -ne 0 ]; then
    echo "Error: Failed to build i3lock-color. Exiting."
    exit 1
fi
sudo make install
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3lock-color. Exiting."
    exit 1
fi

# Verify installation (binary is named i3lock, not i3lock-color)
/usr/local/bin/i3lock --version
if [ $? -ne 0 ]; then
    echo "Error: Failed to verify i3lock-color installation (binary should be i3lock). Exiting."
    exit 1
fi

echo "i3lock-color installation complete."
