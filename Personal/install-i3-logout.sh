#!/bin/bash

# Script to install i3-logout on Linux Mint i3

# Install dependencies
sudo apt install python3 python3-gi libwnck-3-0 -y

# Get the directory where the script is located
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Copy i3-logout files
sudo mkdir -p /usr/share/i3-logout
sudo cp -r "$SCRIPT_DIR/i3-logout/"* /usr/share/i3-logout/
sudo chmod +x /usr/share/i3-logout/i3-logout.py
sudo ln -sf /usr/share/i3-logout/i3-logout.py /usr/bin/i3-logout

# Add shebang to i3-logout.py
if ! grep -q "^#!/usr/bin/env python3" /usr/share/i3-logout/i3-logout.py; then
    sudo sed -i '1i#!/usr/bin/env python3' /usr/share/i3-logout/i3-logout.py
fi

# Verify installation
if command -v i3-logout >/dev/null; then
    echo "i3-logout installed successfully"
else
    echo "Error: i3-logout installation failed"
    exit 1
fi

echo "i3-logout installation complete."
