#!/bin/bash
# installrealvnc.sh – 2025-12-12 FINAL: apt install realvnc-vnc-server

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-realvnc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-realvnc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing RealVNC Server (apt method – works on Mint 22.1)"

# Update and install from Mint repos
sudo apt-get update
sudo apt-get install -y realvnc-vnc-server realvnc-vnc-viewer

# Enable and start service
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo "RealVNC Server installed and running"
echo "Sign in at https://remote.realvnc.com"
