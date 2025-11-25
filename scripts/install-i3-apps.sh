#!/bin/bash
# install-i3-apps.sh – 2025 final: minimal, clean, no dead code

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-apps-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing core i3 apps..."

# SDDM as default (idempotent)
sudo debconf-set-selections <<< "gdm3 shared/default-x-display-manager select sddm"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sddm

sudo apt-get install -y --no-install-recommends \
    feh geany qbittorrent thunar \
    xfce4-settings xfce4-power-manager xfce4-panel \
    network-manager-gnome network-manager-openvpn-gnome \
    arandr audacity brave-browser \
    rsnapshot restic rclone \
    fonts-noto-extra fonts-noto-ui-core fonts-sil-gentium \
    vlc warp-terminal xdotool

# Brave repo (only if not already there)
if ! [[ -f /etc/apt/sources.list.d/brave-browser-release.list ]]; then
    echo "Adding Brave repository..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] \
        https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    sudo apt-get update
fi

# Warp config (always apply – harmless)
mkdir -p "$USER_HOME/.config/warp-terminal"
echo '{"prefs":{"InputPosition":"start_at_the_top"}}' > \
    "$USER_HOME/.config/warp-terminal/user_preferences.json"

echo "i3-apps installation complete"
