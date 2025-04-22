#!/bin/bash

# Script to install GitHub Desktop on Linux Mint via DEB package

# Ensure script is run with sudo for installation
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
DEB_URL="https://github.com/shiftkey/desktop/releases/download/release-3.4.13-linux1/GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
DEB_FILE="/tmp/GitHubDesktop-linux-amd64-3.4.13-linux1.deb"
EXPECTED_SHA256="8b5577761c7900cac2896b5fbc1d88f5aea48b6ce771437262be2a66ab38d987"

# Update package lists
echo "Updating package lists..."
apt update

# Install dependencies
echo "Installing dependencies..."
apt install -y wget

# Download GitHub Desktop DEB package
echo "Downloading GitHub Desktop..."
wget -O "$DEB_FILE" "$DEB_URL"

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

# Clean up
echo "Cleaning up..."
rm -f "$DEB_FILE"

echo "GitHub Desktop installation complete. Launch it from the menu or run 'github-desktop'."
