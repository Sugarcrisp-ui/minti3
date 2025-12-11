#!/bin/bash
# installi3logout.sh – 2025 final: your custom logout menu

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO="$USER_HOME/github-repos/i3-logout"
LOG_DIR="$USER_HOME/log-files/install-i3-logout"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-logout-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing i3-logout (your custom menu)..."

# Dependencies in one shot
sudo apt-get install -y --no-install-recommends \
    python3 python3-gi gir1.2-wnck-3.0 python3-psutil python3-cairo python3-distro

# Clone or update your fork
if [[ -d "$REPO/.git" ]]; then
    git -C "$REPO" pull --ff-only
else
    git clone https://github.com/Sugarcrisp-ui/i3-logout.git "$REPO"
fi

# Install binary + support files
sudo install -Dm755 "$REPO/i3-logout.py" /usr/bin/i3-logout
sudo mkdir -p /usr/share/i3-logout
sudo install -Dm644 "$REPO"/{GUI.py,Functions.py} /usr/share/i3-logout/

# Themes (optional but nice)
if [[ -d "$REPO/themes" ]]; then
    sudo mkdir -p /usr/share/i3-logout-themes/themes
    sudo cp -r "$REPO/themes/"* /usr/share/i3-logout-themes/themes/
fi

# Config restored from external drive later — no GitHub dependency
echo "i3-logout installed — config will be restored from external drive"

echo "i3-logout ready → bind it in your i3 config"
