#!/bin/bash
# installrealvnc.sh – 2025-12-12 FINAL: official RealVNC repo, silent install

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-realvnc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-realvnc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing RealVNC (remote support) from official repo..."

# Add RealVNC GPG key and repository (official method – works on Mint 22.1)
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://archive.realvnc.com/repos/raspbian/public.gpg | sudo tee /etc/apt/keyrings/realvnc.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/realvnc.gpg] https://archive.realvnc.com/repos/raspbian/raspbian bookworm main" | \
    sudo tee /etc/apt/sources.list.d/realvnc.list > /dev/null

# Install VNC Server (64-bit)
sudo apt-get update
sudo apt-get install -y realvnc-vnc-server

# Enable and start service (cloud mode – you’ll sign in later)
sudo systemctl enable vncserver-x11-serviced.service
sudo systemctl start vncserver-x11-serviced.service

echo "RealVNC Server installed and running"
echo "Sign in at https://remote.realvnc.com with your RealVNC account"
