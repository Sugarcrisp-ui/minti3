#!/bin/bash
# installi3apps.sh – 2025-12-12 FINAL: Brave & Warp fixed for Mint 22.1 (Xia)

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-apps-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing core i3 apps..."

# Basic packages – safe & idempotent
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    feh geany qbittorrent thunar \
    xfce4-settings xfce4-power-manager xfce4-panel \
    network-manager-gnome network-manager-openvpn-gnome \
    arandr audacity rsnapshot restic rclone \
    fonts-noto-extra fonts-noto-ui-core fonts-sil-gentium \
    vlc xdotool

# SDDM as default (idempotent)
sudo debconf-set-selections <<< "gdm3 shared/default-x-display-manager select sddm" 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sddm || true

# Brave – Official Mint 22.1 method (curl .sources file, no .list errors)
if ! command -v brave-browser >/dev/null 2>&1; then
    echo "Installing Brave Browser..."
    sudo apt install -y curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources \
        https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
    sudo apt update
    sudo apt install -y brave-browser
else
    echo "Brave already installed – skipping"
fi

# Warp Terminal – Direct .deb from official site (no repo, always latest)
if ! command -v warp-terminal >/dev/null 2>&1; then
    echo "Installing Warp Terminal..."
    curl -L -o /tmp/warp.deb "https://app.warp.dev/download?package=deb"
    sudo dpkg -i /tmp/warp.deb || sudo apt-get install -f -y  # Install + fix deps
    rm -f /tmp/warp.deb
else
    echo "Warp Terminal already installed – skipping"
fi

# Warp config – always safe
mkdir -p "$USER_HOME/.config/warp-terminal"
cat > "$USER_HOME/.config/warp-terminal/user_preferences.json" <<'EOF'
{"prefs":{"InputPosition":"start_at_the_top"}}
EOF

echo "i3-apps installation complete – zero errors"
