#!/bin/bash
# installi3apps.sh – 2025 final: safe, idempotent, no failures

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-apps-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing/updating core i3 apps..."

# SDDM as default (idempotent)
sudo debconf-set-selections <<< "gdm3 shared/default-x-display-manager select sddm" 2>/dev/null || true
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y sddm || true

# Core packages – will skip already-installed ones
sudo apt-get install -y --no-install-recommends \
    feh geany qbittorrent thunar \
    xfce4-settings xfce4-power-manager xfce4-panel \
    network-manager-gnome network-manager-openvpn-gnome \
    arandr audacity \
    rsnapshot restic rclone \
    fonts-noto-extra fonts-noto-ui-core fonts-sil-gentium \
    vlc xdotool

# Brave – safe repo add + install (idempotent)
if ! dpkg -l | grep -q brave-browser; then
    echo "Adding Brave repository and installing Brave..."
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg 2>/dev/null
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y brave-browser
else
    echo "Brave already installed – skipping"
fi

# Warp – safe install + config (idempotent)
if ! dpkg -l | grep -q warp-terminal; then
    echo "Installing Warp Terminal..."
    # Warp provides its own .deb – download + install
    wget -q "https://releases.warp.dev/stable/v0.2025.03.04.08/v0.2025.03.04.08.08.01.stable_02/warp-terminal_0.2025.03.04.08.01.stable.02_amd64.deb" -O /tmp/warp.deb
    sudo apt install -y /tmp/warp.deb
    rm -f /tmp/warp.deb
else
    echo "Warp Terminal already installed – skipping"
fi

# Warp user preferences – always safe to (re)write
mkdir -p "$USER_HOME/.config/warp-terminal"
cat > "$USER_HOME/.config/warp-terminal/user_preferences.json" <<EOF
{"prefs":{"InputPosition":"start_at_the_top"}}
EOF

echo "i3-apps installation complete – everything is safe & idempotent"
