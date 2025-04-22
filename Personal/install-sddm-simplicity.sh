#!/bin/bash

# Install SDDM and dependencies
sudo apt install sddm libqt5quickcontrols2-5 qml-module-qtquick-controls qml-module-qtquick-controls2 -y

# Set SDDM as default display manager (non-interactive)
echo "sddm" | sudo dpkg-reconfigure --frontend noninteractive sddm

# Clone and install sddm-simplicity theme
git clone https://github.com/Sugarcrisp-ui/sddm-themes.git /tmp/sddm-themes
sudo cp -r /tmp/sddm-themes/sddm-simplicity /usr/share/sddm/themes/sddm-simplicity
rm -rf /tmp/sddm-themes

# Configure SDDM to use sddm-simplicity theme
sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]" | sudo tee /etc/sddm.conf.d/kde_settings.conf
echo "Current=sddm-simplicity" | sudo tee -a /etc/sddm.conf.d/kde_settings.conf

# Verify SDDM configuration
cat /etc/sddm.conf.d/kde_settings.conf
