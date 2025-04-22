#!/bin/bash

# Script to install GitHub Desktop on Linux Mint via DEB package and set up cron job for updates

# Ensure script is run with sudo for installation
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
DEB_URL="https://github.com/shiftkey/desktop/releases/download/release-3.4.13-linux1/GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
FALLBACK_URL="https://github.com/shiftkey/desktop/releases/download/release-3.4.13-linux1/GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
DEB_FILE="/tmp/GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
INSTALL_DIR="/tmp/github-desktop-install"
EXPECTED_SHA256="8b5577761c7900cac2896b5fbc1d88f5aea48b6ce771437262be2a66ab38d987"
CRON_JOB="0 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-github-desktop.sh >> /home/brett/minti3/Personal/github-desktop-update.log 2>&1"
CRONTAB_FILE="/tmp/crontab.tmp"
USER="brett"

# Create temporary directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Update package lists
echo "Updating package lists..."
apt update

# Install dependencies
echo "Installing dependencies..."
apt install -y wget

# Download GitHub Desktop DEB package
echo "Downloading GitHub Desktop..."
wget -O "$DEB_FILE" "$DEB_URL" || wget -O "$DEB_FILE" "$FALLBACK_URL"

# Check if download was successful
if [ ! -f "$DEB_FILE" ]; then
    echo "Error: Failed to download GitHub Desktop package"
    exit 1
fi

# Verify checksum
echo "Verifying download integrity..."
DOWNLOADED_SHA256=$(sha256sum "$DEB_FILE" | awk '{print $1}')
if [ "$DOWNLOADED_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "Error: Checksum mismatch. Downloaded file is corrupted."
    echo "Expected: $EXPECTED_SHA256"
    echo "Got: $DOWNLOADED_SHA256"
    rm -f "$DEB_FILE"
    exit 1
fi

# Install GitHub Desktop
echo "Installing GitHub Desktop..."
dpkg -i "$DEB_FILE"
apt install -f -y

# Verify installation
if command -v github-desktop >/dev/null; then
    echo "GitHub Desktop installed successfully"
else
    echo "Error: GitHub Desktop installation failed"
    exit 1
fi

# Set up cron job for updates
echo "Setting up cron job to update GitHub Desktop at 9 PM on Sundays..."
sudo -u "$USER" crontab -l > "$CRONTAB_FILE" 2>/dev/null || touch "$CRONTAB_FILE"
if ! grep -Fx "$CRON_JOB" "$CRONTAB_FILE" > /dev/null; then
    echo "$CRON_JOB" >> "$CRONTAB_FILE"
    sudo -u "$USER" crontab "$CRONTAB_FILE"
    if [ $? -eq 0 ]; then
        echo "Cron job added successfully"
    else
        echo "Error: Failed to add cron job"
        exit 1
    fi
else
    echo "Cron job already exists"
fi

# Clean up
echo "Cleaning up..."
rm -rf "$INSTALL_DIR" "$DEB_FILE" "$CRONTAB_FILE"

echo "GitHub Desktop installation and cron job setup complete. Launch it from the menu or run 'github-desktop'."
