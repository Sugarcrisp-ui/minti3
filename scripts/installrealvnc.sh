#!/bin/bash
# installrealvnc.sh – 2025 final: official repo, no downloads

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-realvnc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-realvnc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing RealVNC (remote support) from official repo..."

# Add RealVNC repo (idempotent)
if ! [[ -f /etc/apt/sources.list.d/realvnc.list ]]; then
    wget -qO- https://downloads.realvnc.com/download/file/vnc.files/realvnc-repo.asc | sudo tee /etc/apt/trusted.gpg.d/realvnc.gpg >/dev/null
    echo "deb https://downloads.realvnc.com/download/file/vnc.files realvnc noble main" | sudo tee /etc/apt/sources.list.d/realvnc.list >/dev/null
    sudo apt-get update
fi

# Install
sudo apt-get install -y --no-install-recommends realvnc-vnc-server realvnc-vnc-viewer

# Enable service
sudo systemctl enable --now vncserver-x11-serviced 2>/dev/null || true

echo "RealVNC installed → sign in with your RealVNC account to configure"
