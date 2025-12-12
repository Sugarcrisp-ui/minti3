#!/bin/bash
# installi3lockcolor.sh – 2025-12-12 FINAL: works on fresh Mint 22.1 T14

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-i3lock-color"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-i3lock-color-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing i3lock-color..."

# Install build dependencies once
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    autoconf automake pkg-config libpam0g-dev \
    libcairo2-dev libxcb1-dev libxcb-util0-dev \
    libev-dev libx11-xcb-dev libxcb-xrm-dev \
    libxcb-randr0-dev libxcb-xinerama0-dev \
    libxcb-composite0-dev libxcb-image0-dev \
    libjpeg-dev libxcb-xkb-dev libxkbcommon-dev \
    libxkbcommon-x11-dev libxcb-dpms0-dev

# Clone or update the repo
REPO_DIR="$USER_HOME/github-repos/i3lock-color"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning i3lock-color repo..."
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone https://github.com/Raymo111/i3lock-color.git "$REPO_DIR"
else
    echo "Updating existing i3lock-color repo..."
    (cd "$REPO_DIR" && git pull --ff-only)
fi

# Build and install
cd "$REPO_DIR"
echo "Building i3lock-color..."
autoreconf -fiv
./configure
make -j$(nproc)
sudo make install

echo "i3lock-color installed successfully"
echo "Test with: i3lock --color=333333"
