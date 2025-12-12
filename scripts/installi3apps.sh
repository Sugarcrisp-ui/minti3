#!/bin/bash
# installi3apps.sh – 2025-12-12 ETERNAL FINAL: Brave & Warp work on every future Mint/Ubuntu machine

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-apps-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing core i3 apps..."

# Basic packages
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    feh geany qbittorrent thunar \
    xfce4-settings xfce4-power-manager xfce4-panel \
    network-manager-gnome network-manager-openvpn-gnome \
    arandr audacity rsnapshot restic rclone \
    fonts-noto-extra fonts-noto-ui-core fonts-sil-gentium \
    vlc xdotool

# SDDM as default
sudo debconf-set-selections <<< "gdm3 shared/default-x-display-manager select sddm" 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sddm || true

# Brave – official method that survives every Mint/Ubuntu version change
if ! command -v brave-browser >/dev/null 2>&1; then
    echo "Installing Brave Browser (official 2025+ method)..."
    sudo apt install -y curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSLo /etc/apt/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    sudo apt update
    sudo apt install -y brave-browser
else
    echo "Brave already installed – skipping"
fi

# Warp Terminal – official apt repo (no .deb download flakiness)
if ! command -v warp-terminal >/dev/null 2>&1; then
    echo "Installing Warp Terminal (official apt repo)..."
    sudo apt install -y wget gpg
    wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor | \
        sudo tee /usr/share/keyrings/warpdotdev-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/warpdotdev-archive-keyring.gpg] https://releases.warp.dev/linux/deb stable main" | \
        sudo tee /etc/apt/sources.list.d/warpdotdev.list >/dev/null
    sudo apt update
    sudo apt install -y warp-terminal
else
    echo "Warp Terminal already installed – skipping"
fi

# Warp config
mkdir -p "$USER_HOME/.config/warp-terminal"
cat > "$USER_HOME/.config/warp-terminal/user_preferences.json" <<'EOF'
{"prefs":{"InputPosition":"start_at_the_top"}}
EOF

echo "i3-apps installation complete – future-proof"
