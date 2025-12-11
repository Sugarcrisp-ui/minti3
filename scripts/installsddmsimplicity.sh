#!/bin/bash
# installsddmsimplicity.sh – 2025 final: your custom SDDM theme

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/tmp/sddm-themes"
LOG_DIR="$USER_HOME/log-files/install-sddm-simplicity"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-sddm-simplicity-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing SDDM + simplicity theme..."

# Dependencies + SDDM in one shot
sudo apt-get install -y --no-install-recommends \
    sddm libqt5quickcontrols2-5 qml-module-qtquick-controls qml-module-qtquick-controls2

# Clone or update your fork (your custom version)
if [[ -d "$REPO_DIR/.git" ]]; then
    git -C "$REPO_DIR" pull --ff-only
else
    git clone https://github.com/Sugarcrisp-ui/sddm-themes.git "$REPO_DIR"
fi

# Install theme
sudo cp -r "$REPO_DIR/sddm-simplicity" /usr/share/sddm/themes/

# Configure SDDM (idempotent)
sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
echo "Current=sddm-simplicity" | sudo tee -a /etc/sddm.conf.d/theme.conf >/dev/null

echo "SDDM + simplicity theme installed"
echo "   → Reboot to see your custom theme"
