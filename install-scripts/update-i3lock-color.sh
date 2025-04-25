#!/bin/bash

# Script to install i3lock-color from source and set up cron job for updates on Linux Mint

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
REPO_URL="https://github.com/Raymo111/i3lock-color"
SRC_DIR="/home/brett/i3lock-color"
TEMP_DIR="/tmp/i3lock-color-install"
CRON_JOB="# Update i3lock-color every Sunday at 9:20 PM\n20 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-i3lock-color.sh >> /home/brett/minti3/Personal/i3lock-color-update.log 2>&1"
CRONTAB_FILE="/tmp/crontab.root.tmp"

# Install build dependencies
echo "Installing build dependencies..."
apt update
apt install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev git

# Clone repository
echo "Cloning i3lock-color repository..."
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$SRC_DIR"
    git clone "$REPO_URL" "$SRC_DIR"
fi

# Build and install
echo "Building and installing i3lock-color..."
cd "$SRC_DIR"
autoreconf -fi
./configure --enable-debug=no --disable-sanitizers
make
make install

# Verify installation
if command -v i3lock >/dev/null; then
    echo "i3lock-color installed successfully"
else
    echo "Error: i3lock-color installation failed"
    exit 1
fi

# Set up cron job for updates in root crontab
echo "Setting up cron job to update i3lock-color at 9:20 PM on Sundays..."
sudo crontab -l > "$CRONTAB_FILE" 2>/dev/null || touch "$CRONTAB_FILE"
if ! grep -F "$CRON_JOB" "$CRONTAB_FILE" >/dev/null; then
    echo -e "$CRON_JOB" >> "$CRONTAB_FILE"
    sudo crontab "$CRONTAB_FILE"
    if [ $? -eq 0 ]; then
        echo "Cron job added successfully to root crontab"
    else
        echo "Error: Failed to add cron job to root crontab"
        exit 1
    fi
else
    echo "Cron job already exists in root crontab"
fi

# Clean up
echo "Cleaning up..."
rm -rf "$TEMP_DIR" "$CRONTAB_FILE"

echo "i3lock-color installation and cron job setup complete."
