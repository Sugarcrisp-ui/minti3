#!/bin/bash
# installrealvnc.sh – 2025-12-12 FINAL: direct .deb from user-provided links

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-realvnc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-realvnc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing RealVNC Server & Viewer (direct .deb from provided links)"

# Download VNC Viewer
VNC_VIEWER_DEB="/tmp/VNC-Viewer-7.15.1-Linux-x64.deb"
echo "Downloading VNC Viewer..."
curl -L -o "$VNC_VIEWER_DEB" "https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.15.1-Linux-x64.deb?lai_vid=OXx36M4lkfXWD&lai_sr=0-4&lai_sl=l"

# Download VNC Server
VNC_SERVER_DEB="/tmp/VNC-Server-7.16.0-Linux-x64.deb"
echo "Downloading VNC Server..."
curl -L -o "$VNC_SERVER_DEB" "https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-7.16.0-Linux-x64.deb?lai_vid=OXx36M4lkfXWD&lai_sr=0-4&lai_sl=l"

# Install Viewer
echo "Installing VNC Viewer..."
sudo dpkg -i "$VNC_VIEWER_DEB" || sudo apt-get install -f -y

# Install Server
echo "Installing VNC Server..."
sudo dpkg -i "$VNC_SERVER_DEB" || sudo apt-get install -f -y

# Clean up
rm -f "$VNC_VIEWER_DEB" "$VNC_SERVER_DEB"

# Enable and start service
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo "RealVNC Server & Viewer installed and running"
echo "Sign in at https://remote.realvnc.com"
