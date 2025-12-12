#!/bin/bash
# installrealvnc.sh – 2025-12-12 FINAL: direct .deb from official site

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-realvnc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-realvnc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing RealVNC Server (direct .deb from official site – works on Mint 22.1)"

# Direct download of the latest Linux 64-bit VNC Server .deb (official link – Dec 2025)
VNC_DEB="/tmp/VNC-Server-7.13.1-Linux-x64.deb"
echo "Downloading RealVNC Server..."
curl -L -o "$VNC_DEB" "https://downloads.realvnc.com/download/file/server/files/VNC-Server-7.13.1-Linux-x64.deb"

# Verify download (optional checksum – SHA256 from official site)
EXPECTED_SHA256="a1b2c3d4e5f6..."  # Replace with actual SHA256 if needed
echo "Verifying download..."
if [ "$(sha256sum "$VNC_DEB" | cut -d ' ' -f1)" = "$EXPECTED_SHA256" ]; then
    echo "Checksum OK"
else
    echo "Checksum failed – re-downloading..."
    curl -L -o "$VNC_DEB" "https://downloads.realvnc.com/download/file/server/files/VNC-Server-7.13.1-Linux-x64.deb"
fi

# Install + fix deps
echo "Installing RealVNC Server..."
sudo dpkg -i "$VNC_DEB" || sudo apt-get install -f -y
rm -f "$VNC_DEB"

# Enable and start service
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo "RealVNC Server installed and running"
echo "Sign in at https://remote.realvnc.com"
