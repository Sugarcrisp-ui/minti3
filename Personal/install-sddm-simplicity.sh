#!/bin/bash

# Install SDDM and dependencies
sudo apt install sddm libqt5quickcontrols2-5 qml-module-qtquick-controls qml-module-qtquick-controls2 -y

# Set SDDM as default display manager
sudo dpkg-reconfigure sddm
# Note: Select 'sddm' in the interactive menu if prompted

# Clone and install arcolinux-simplicity theme
git clone https://github.com/Sugarcrisp-ui/sddm-themes.git ~/sddm-themes
sudo cp -r ~/sddm-themes/arcolinux-simplicity /usr/share/sddm/themes/arcolinux-simplicity

# Configure SDDM to use arcolinux-simplicity theme
sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]" | sudo tee /etc/sddm.conf.d/kde_settings.conf
echo "Current=arcolinux-simplicity" | sudo tee -a /etc/sddm.conf.d/kde_settings.conf

# Verify SDDM configuration
cat /etc/sddm.conf.d/kde_settings.conf