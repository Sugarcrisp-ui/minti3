#!/bin/bash

# Install SDDM and dependencies
apt-get update
apt-get install -y sddm libqt5quickcontrols2-5 qml-module-qtquick-controls qml-module-qtquick-controls2 git
if [ $? -ne 0 ]; then
    echo "Error: Failed to install SDDM and dependencies. Exiting."
    exit 1
fi

# Clone or update sddm-themes repository
if [ ! -d "/tmp/sddm-themes" ]; then
    echo "Cloning sddm-themes repository..."
    git clone https://github.com/Skanderkam/sddm-themes.git /tmp/sddm-themes
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone sddm-themes repository. Exiting."
        exit 1
    fi
else
    echo "sddm-themes repository already exists at /tmp/sddm-themes, updating..."
    cd /tmp/sddm-themes
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update sddm-themes repository. Exiting."
        exit 1
    fi
fi

# Install the simplicity theme
cp -r /tmp/sddm-themes/simplicity /usr/share/sddm/themes/

# Configure SDDM to use the simplicity theme
echo "[Theme]" > /etc/sddm.conf
echo "Current=simplicity" >> /etc/sddm.conf

echo "SDDM and simplicity theme installation complete."
