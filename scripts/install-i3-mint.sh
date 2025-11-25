#!/bin/bash
# install-i3-mint.sh – 2025 final: core i3 + polybar + rofi + dunst

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-mint"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-mint-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing core i3 environment..."

# Update once
sudo apt-get update

# Core packages in one shot (no build deps — those live in i3lock-color)
sudo apt-get install -y --no-install-recommends \
    i3 i3status rofi dunst polybar \
    xfce4-terminal micro copyq blueman pasystray

# Config dirs (idempotent)
mkdir -p "$USER_HOME/.config"/{i3,polybar,rofi,dunst}

echo "i3 + polybar + rofi + dunst installed"
echo "   → i3 version: $(i3 --version 2>/dev/null || echo 'unknown')"
echo "   → polybar:    $(polybar --version 2>/dev/null || echo 'not found')"
echo "   → rofi:       $(rofi -v 2>/dev/null || echo 'not found')"
echo "   → dunst:      $(dunst -v 2>/dev/null || echo 'not found')"

echo "i3-mint core installation complete"
