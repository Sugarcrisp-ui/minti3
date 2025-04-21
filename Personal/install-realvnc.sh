#!/bin/bash

# Script to automate RealVNC Connect (Server and Viewer) installation on Linux Mint

# Ensure script is run with sudo for installation
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
SERVER_DOWNLOAD_URL="https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-7.13.0-Linux-x64.deb"
VIEWER_DOWNLOAD_URL="https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.13.0-Linux-x64.deb"
SERVER_DEB_FILE="/tmp/VNC-Server-7.13.0-Linux-x64.deb"
VIEWER_DEB_FILE="/tmp/VNC-Viewer-7.13.0-Linux-x64.deb"
INSTALL_DIR="/tmp/realvnc-install"

# Create temporary directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Update package lists
echo "Updating package lists..."
apt update

# Install dependencies
echo "Installing dependencies..."
apt install -y wget xterm

# Download RealVNC Server DEB package
echo "Downloading RealVNC Server..."
wget -O "$SERVER_DEB_FILE" "$SERVER_DOWNLOAD_URL"

# Check if download was successful
if [ ! -f "$SERVER_DEB_FILE" ]; then
    echo "Error: Failed to download RealVNC Server package"
    exit 1
fi

# Download RealVNC Viewer DEB package
echo "Downloading RealVNC Viewer..."
wget -O "$VIEWER_DEB_FILE" "$VIEWER_DOWNLOAD_URL"

# Check if download was successful
if [ ! -f "$VIEWER_DEB_FILE" ]; then
    echo "Error: Failed to download RealVNC Viewer package"
    exit 1
fi

# Install RealVNC Server
echo "Installing RealVNC Server..."
dpkg -i "$SERVER_DEB_FILE"
apt install -f -y

# Install RealVNC Viewer
echo "Installing RealVNC Viewer..."
dpkg -i "$VIEWER_DEB_FILE"
apt install -f -y

# Verify installation
if command -v vncserver-x11 >/dev/null && command -v vncviewer >/dev/null; then
    echo "RealVNC Server and Viewer installed successfully"
else
    echo "Error: RealVNC installation failed"
    echo "Available VNC commands:"
    ls -l /usr/bin/vnc*
    exit 1
fi

# Clean up
echo "Cleaning up..."
rm -rf "$INSTALL_DIR" "$SERVER_DEB_FILE" "$VIEWER_DEB_FILE"

# Start RealVNC Server service
echo "Starting RealVNC Server service..."
systemctl enable vncserver-x11-serviced
systemctl start vncserver-x11-serviced

echo "RealVNC installation complete. Sign in with your free RealVNC account to configure."
