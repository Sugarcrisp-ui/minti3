#!/bin/bash

# Install dependencies for i3-logout and betterlockscreen
apt-get install -y python3 python3-gi libwnck-3-0
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies for i3-logout and betterlockscreen. Exiting."
    exit 1
fi

# Clone or update i3-logout repository
if [ ! -d "/home/brett/i3-logout" ]; then
    echo "Cloning i3-logout repository..."
    git clone https://github.com/esn89/i3-logout.git /home/brett/i3-logout
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

# Install i3-logout
cp -r /home/brett/i3-logout/i3-logout /usr/local/bin/
chmod +x /usr/local/bin/i3-logout

# Install betterlockscreen
wget https://github.com/betterlockscreen/betterlockscreen/releases/download/v4.3.0/betterlockscreen -O /usr/local/bin/betterlockscreen
chmod +x /usr/local/bin/betterlockscreen

# Verify installations
i3-logout --version
betterlockscreen --version

echo "i3-logout and betterlockscreen installation complete."
