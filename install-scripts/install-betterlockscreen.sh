#!/bin/bash

# Install dependencies
sudo apt install python3 python3-gi libwnck-3-0 i3lock imagemagick feh x11-xserver-utils x11-utils libgtk-3-0 python3-gi gir1.2-gtk-3.0 -y

# Copy betterlockscreen files from archlinux-logout tarball
sudo mkdir -p /usr/share/archlinux-betterlockscreen
sudo cp /tmp/archlinux-logout/usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py /usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py
sudo cp -r /tmp/archlinux-logout/usr/share/archlinux-betterlockscreen/* /usr/share/archlinux-betterlockscreen/
sudo chmod +x /usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py
sudo ln -sf /usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py /usr/bin/betterlockscreen

# Add shebang to betterlockscreen.py
if ! grep -q "^#!/usr/bin/env python3" /usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py; then
    sudo sed -i '1i#!/usr/bin/env python3' /usr/share/archlinux-betterlockscreen/archlinux-betterlockscreen.py
fi

# Verify installation
betterlockscreen --version