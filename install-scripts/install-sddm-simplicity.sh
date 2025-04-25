#!/bin/bash

# Install SDDM and dependencies
echo "Installing SDDM and dependencies..."
sudo apt-get update
sudo apt-get install -y sddm libqt5quickcontrols2-5 qml-module-qtquick-controls qml-module-qtquick-controls2 git
if [ $? -ne 0 ]; then
    echo "Error: Failed to install SDDM and dependencies. Exiting."
    exit 1
fi

# Clone or update sddm-themes repository
if [ ! -d "/tmp/sddm-themes/.git" ]; then
    echo "Cloning sddm-themes repository..."
    git clone git@github.com:Sugarcrisp-ui/sddm-themes.git /tmp/sddm-themes
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

# Install the sddm-simplicity theme
sudo cp -r /tmp/sddm-themes/sddm-simplicity /usr/share/sddm/themes/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install sddm-simplicity theme. Exiting."
    exit 1
fi

# Configure SDDM to use the sddm-simplicity theme
echo "[Theme]" | sudo tee /etc/sddm.conf
echo "Current=sddm-simplicity" | sudo tee -a /etc/sddm.conf
if [ $? -ne 0 ]; then
    echo "Error: Failed to configure SDDM to use sddm-simplicity theme. Exiting."
    exit 1
fi

echo "SDDM and sddm-simplicity theme installation complete."
