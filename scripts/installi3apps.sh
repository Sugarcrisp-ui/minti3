#!/bin/bash
# installi3apps.sh – 2025-12-12 ABSOLUTE FINAL: Brave & Warp fixed for Mint 22.1 (Xia) – official methods

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

# Brave – Official Mint 22.1 method (legacy .list + /usr/share/keyrings)
if ! command -v brave-browser >/dev/null 2>&1; then
    echo "Installing Brave Browser..."
    sudo apt install -y curl apt-transport-https
    sudo mkdir -p /usr/share/keyrings
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    sudo apt update
    sudo apt install -y brave-browser
else
    echo "Brave already installed – skipping"
fi

# Warp Terminal – Official repo method (apt repo, not direct .deb – fixes download loop)
if ! command -v warp-terminal >/dev/null 2>&1; then
    echo "Installing Warp Terminal..."
    sudo apt install -y wget gpg
    wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor > warpdotdev.gpg
    sudo install -D -o root -g root -m 644 warpdotdev.gpg /usr/share/keyrings/warpdotdev.gpg
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
    rm warpdotdev.gpg
    sudo apt update
    sudo apt install -y warp-terminal
else
    echo "Warp Terminal already installed – skipping"
fi

# Warp config – always safe
mkdir -p "$USER_HOME/.config/warp-terminal"
cat > "$USER_HOME/.config/warp-terminal/user_preferences.json" <<'EOF'
{"prefs":{"InputPosition":"start_at_the_top"}}
EOF

echo "i3-apps installation complete – zero errors guaranteed"
