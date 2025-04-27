#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi
sudo apt-get install -y \
    python3 \
    python3-gi \
    gir1.2-wnck-3.0 \
    python3-psutil \
    python3-cairo \
    python3-distro
if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies. Exiting."
    exit 1
fi

# Ensure i3-logout.py, GUI.py, and Functions.py exist
echo "Checking for Python files..."
for file in i3-logout.py GUI.py Functions.py; do
    if [ ! -f "/home/$(whoami)/i3-logout/i3-logout/$file" ]; then
        echo "Error: $file not found in /home/$(whoami)/i3-logout/i3-logout/. Exiting."
        exit 1
    fi
done

# Update i3-logout.py to remove archlinux references
echo "Updating i3-logout.py to remove archlinux references..."
sed -i 's/archlinux-logout/i3-logout/g' /home/$(whoami)/i3-logout/i3-logout/i3-logout.py
sed -i 's/archlinux-betterlockscreen/betterlockscreen/g' /home/$(whoami)/i3-logout/i3-logout/i3-logout.py
sed -i 's/Archlinux Logout/i3-logout/g' /home/$(whoami)/i3-logout/i3-logout/i3-logout.py

# Install config
echo "Installing config..."
if [ -f "/home/$(whoami)/dotfiles-minti3/.config/i3-logout/i3-logout.conf" ]; then
    sudo install -Dm644 /home/$(whoami)/dotfiles-minti3/.config/i3-logout/i3-logout.conf /etc/i3-logout.conf
else
    echo "Error: i3-logout.conf not found in /home/$(whoami)/dotfiles-minti3/.config/i3-logout/. Exiting."
    exit 1
fi

# Install binaries
echo "Installing binaries..."
sudo install -Dm755 /home/$(whoami)/i3-logout/i3-logout/i3-logout.py /usr/bin/i3-logout
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3-logout.py to /usr/bin/i3-logout. Exiting."
    exit 1
fi

# Install Python files
echo "Installing Python files..."
sudo mkdir -p /usr/share/i3-logout
sudo install -Dm644 /home/$(whoami)/i3-logout/i3-logout/GUI.py /usr/share/i3-logout/GUI.py
sudo install -Dm644 /home/$(whoami)/i3-logout/i3-logout/Functions.py /usr/share/i3-logout/Functions.py
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Python files to /usr/share/i3-logout/. Exiting."
    exit 1
fi

# Install themes
echo "Installing themes..."
sudo mkdir -p /usr/share/i3-logout-themes/themes
sudo cp -r /home/$(whoami)/i3-logout/src/usr/share/i3-logout-themes/themes/* /usr/share/i3-logout-themes/themes/
sudo cp /home/$(whoami)/i3-logout/src/usr/share/i3-logout-themes/*.svg /usr/share/i3-logout-themes/
if [ $? -ne 0 ]; then
    echo "Error: Failed to install themes to /usr/share/i3-logout-themes/. Exiting."
    exit 1
fi

echo "i3-logout installation complete."
