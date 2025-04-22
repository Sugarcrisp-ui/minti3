#!/bin/bash

# Install SDDM and dependencies
sudo apt-get update
sudo apt-get install -y \
  sddm \
  libqt5quickcontrols2-5 \
  qml-module-qtquick-controls \
  qml-module-qtquick-controls2 \
  git

# Set SDDM as default display manager (non-interactive)
echo "sddm" | sudo dpkg-reconfigure --frontend noninteractive sddm

# Clone and install sddm-simplicity theme
git clone https://github.com/Sugarcrisp-ui/sddm-themes.git /tmp/sddm-themes
if [ ! -d "/tmp/sddm-themes/sddm-simplicity" ]; then
    echo "Error: sddm-simplicity directory not found in cloned repository"
    exit 1
fi
sudo cp -r /tmp/sddm-themes/sddm-simplicity /usr/share/sddm/themes/sddm-simplicity
rm -rf /tmp/sddm-themes

# Configure SDDM to use sddm-simplicity theme
sudo mkdir -p /etc/sddm.conf.d
sudo bash -c 'cat > /etc/sddm.conf.d/kde_settings.conf << EOF
[Theme]
Current=sddm-simplicity
EOF'

# Verify SDDM configuration
cat /etc/sddm.conf.d/kde_settings.conf
