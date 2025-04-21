#!/bin/bash

# Install dependencies
sudo apt install python3 python3-gi libwnck-3-0 gir1.2-gtk-3.0 -y

# Clone archlinux-logout from GitHub
git clone https://github.com/Sugarcrisp-ui/archlinux-logout.git ~/archlinux-logout
cd ~/archlinux-logout

# Extract tarball
mkdir -p /tmp/archlinux-logout
tar -xzf archlinux-logout-files.tar.gz -C /tmp/archlinux-logout

# Install files
sudo mkdir -p /usr/share/archlinux-logout
sudo cp /tmp/archlinux-logout/usr/share/archlinux-logout/archlinux-logout.py /usr/share/archlinux-logout/archlinux-logout.py
sudo cp -r /tmp/archlinux-logout/usr/share/archlinux-logout/* /usr/share/archlinux-logout/
sudo cp -r /tmp/archlinux-logout/usr/share/archlinux-logout-themes /usr/share/archlinux-logout-themes
sudo cp /tmp/archlinux-logout/etc/archlinux-logout.conf /etc/
sudo chmod +x /usr/share/archlinux-logout/archlinux-logout.py
sudo ln -sf /usr/share/archlinux-logout/archlinux-logout.py /usr/bin/archlinux-logout

# Add shebang if missing
if ! grep -q "^#!/usr/bin/env python3" /usr/share/archlinux-logout/archlinux-logout.py; then
    sudo sed -i '1i#!/usr/bin/env python3' /usr/share/archlinux-logout/archlinux-logout.py
fi

# Verify installation
archlinux-logout --version