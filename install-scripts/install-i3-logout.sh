#!/bin/bash

# Install dependencies
echo "Installing dependencies for i3-logout and betterlockscreen..."
sudo apt-get install -y libimlib2-dev libx11-dev libgtk-3-dev libpam0g-dev
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies for i3-logout and betterlockscreen. Exiting."
    exit 1
fi

# Clone or update i3-logout repository
if [ ! -d "/home/brett/i3-logout" ]; then
    echo "Cloning i3-logout repository..."
    git clone https://github.com/nwhirschfeld/i3-logout.git /home/brett/i3-logout
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3-logout repository. Exiting."
        exit 1
    fi
else
    echo "i3-logout repository already exists at /home/brett/i3-logout, updating..."
    cd /home/brett/i3-logout
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update i3-logout repository. Exiting."
        exit 1
    fi
fi

# Build and install i3-logout
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

# Install betterlockscreen
wget https://github.com/betterlockscreen/betterlockscreen/archive/refs/heads/main.zip
if [ $? -ne 0 ]; then
    echo "Error: Failed to download betterlockscreen. Exiting."
    exit 1
fi
unzip main.zip
if [ $? -ne 0 ]; then
    echo "Error: Failed to unzip betterlockscreen. Exiting."
    exit 1
fi
mv betterlockscreen-main betterlockscreen
cd betterlockscreen
chmod +x betterlockscreen
sudo mv betterlockscreen /usr/local/bin/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install betterlockscreen. Exiting."
    exit 1
fi

# Verify installations
i3-logout --version
if [ $? -ne 0 ]; then
    echo "Error: Failed to verify i3-logout installation. Exiting."
    exit 1
fi
/usr/local/bin/betterlockscreen --version
if [ $? -ne 0 ]; then
    echo "Error: Failed to verify betterlockscreen installation. Exiting."
    exit 1
fi

echo "i3-logout and betterlockscreen installation complete."
