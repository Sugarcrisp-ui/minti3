#!/bin/bash

# Script to install i3-logout and betterlockscreen on Linux Mint i3

# Install dependencies
sudo apt install -y \
  python3 \
  python3-gi \
  libwnck-3-0

# Variables
USER="brett"
USER_HOME="/home/$USER"
I3_LOGOUT_DIR="$USER_HOME/i3-logout"

# Copy i3-logout files
sudo mkdir -p /usr/share/i3-logout
sudo cp -r "$I3_LOGOUT_DIR/i3-logout/"* /usr/share/i3-logout/
sudo chmod +x /usr/share/i3-logout/i3-logout.py
sudo ln -sf /usr/share/i3-logout/i3-logout.py /usr/bin/i3-logout

# Add shebang to i3-logout.py
if ! grep -q "^#!/usr/bin/env python3" /usr/share/i3-logout/i3-logout.py; then
    sudo sed -i '1i#!/usr/bin/env python3' /usr/share/i3-logout/i3-logout.py
fi

# Copy betterlockscreen files and rename
sudo mkdir -p /usr/share/betterlockscreen
sudo cp -r "$I3_LOGOUT_DIR/src/usr/share/betterlockscreen/"* /usr/share/betterlockscreen/
sudo mv /usr/share/betterlockscreen/archlinux-betterlockscreen.py /usr/share/betterlockscreen/betterlockscreen.py
sudo chmod +x /usr/share/betterlockscreen/betterlockscreen.py
sudo ln -sf /usr/share/betterlockscreen/betterlockscreen.py /usr/bin/betterlockscreen

# Add shebang to betterlockscreen.py
if ! grep -q "^#!/usr/bin/env python3" /usr/share/betterlockscreen/betterlockscreen.py; then
    sudo sed -i '1i#!/usr/bin/env python3' /usr/share/betterlockscreen/betterlockscreen.py
fi

# Verify installation
if command -v i3-logout >/dev/null && command -v betterlockscreen >/dev/null; then
    echo "i3-logout and betterlockscreen installed successfully"
else
    echo "Error: Installation failed"
    exit 1
fi

echo "Installation complete."
