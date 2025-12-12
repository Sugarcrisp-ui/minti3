#!/bin/bash
# installbetterlockscreen.sh – 2025-12-12 FINAL: works after i3lock-color is in /usr/local/bin

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-betterlockscreen"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-betterlockscreen-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing betterlockscreen (Tesla Model S lock screen)..."

# Make sure /usr/local/bin is in PATH for this session
export PATH="/usr/local/bin:$PATH"

# betterlockscreen depends on i3lock-color being available as 'i3lock'
if ! command -v i3lock >/dev/null 2>&1; then
    echo "Creating i3lock symlink so betterlockscreen finds i3lock-color..."
    sudo ln -sf /usr/local/bin/i3lock /usr/local/bin/i3lock-color-wrapper
    sudo ln -sf /usr/local/bin/i3lock /usr/bin/i3lock
fi

# Install dependencies
sudo apt-get update
sudo apt-get install -y bc curl imagemagick feh

# Clone or update betterlockscreen
REPO_DIR="$USER_HOME/betterlockscreen"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning betterlockscreen..."
    git clone --depth 1 https://github.com/pavanjadhaw/betterlockscreen.git "$REPO_DIR"
else
    echo "Updating existing betterlockscreen..."
    (cd "$REPO_DIR" && git pull --ff-only)
fi

# Install
cd "$REPO_DIR"
sudo cp betterlockscreen /usr/local/bin/
sudo chmod +x /usr/local/bin/betterlockscreen

# Pre-cache your wallpaper (Tesla Model S – change path if you use a different one)
WALLPAPER="$USER_HOME/Pictures/tesla-model-s.jpg"
if [ -f "$WALLPAPER" ]; then
    echo "Pre-caching Tesla Model S wallpaper..."
    betterlockscreen -u "$WALLPAPER" --fx blur
else
    echo "Tesla wallpaper not found – skipping cache (you can run manually later)"
fi

echo "betterlockscreen installed and ready"
echo "Test with: betterlockscreen --lock"
