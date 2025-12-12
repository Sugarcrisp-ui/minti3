#!/bin/bash
# installi3apps.sh – 2025-12 final: works on fresh Mint 22.1 / T14

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3-apps"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3-apps-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing core i3 apps..."

# Basic packages – always safe
sudo apt-get install -y --no-install-recommends \
    feh geany qbittorrent thunar \
    xfce4-settings xfce4-power-manager xfce4-panel \
    network-manager-gnome network-manager-openvpn-gnome \
    arandr audacity rsnapshot restic rclone \
    fonts-noto-extra fonts-noto-ui-core fonts-sil-gentium \
    vlc xdotool

# Brave – Mint 22+ compatible, fully idempotent
if ! dpkg -l | grep -q brave-browser; then
    echo "Adding Brave repository (Mint 22+ format)..."
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSLo /etc/apt/keyrings/brave-browser-archive-keyring.gpg \
        https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.sources >/dev/null
    sudo apt-get update
    sudo apt-get install -y brave-browser
else
    echo "Brave already installed"
fi

# Warp Terminal – fetch latest .deb directly (always works)
if ! dpkg -l | grep -q warp-terminal; then
    echo "Installing latest Warp Terminal..."
    curl -L -o /tmp/warp.deb "https://app.warp.dev/download?package=deb"
    sudo apt install -y /tmp/warp.deb || sudo apt-get install -f -y
    rm -f /tmp/warp.deb
else
    echo "Warp Terminal already installed"
fi

# Warp config – always safe to write
mkdir -p "$USER_HOME/.config/warp-terminal"
cat > "$USER_HOME/.config/warp-terminal/user_preferences.json" <<'EOF'
{"prefs":{"InputPosition":"start_at_the_top"}}
EOF

echo "i3-apps installation complete"
