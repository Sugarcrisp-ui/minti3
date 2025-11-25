#!/bin/bash
# install-xfce-theme.sh – 2025 final: Arc-Darker theme (your look)

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

LOG_DIR="${HOME:?}/log-files/install-xfce-theme"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-xfce-theme-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing + applying Arc-Darker theme..."

# Install in one shot
sudo apt-get install -y --no-install-recommends arc-theme xfce4-settings

# Apply theme (idempotent)
xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker" 2>/dev/null || true

echo "Arc-Darker theme applied"
