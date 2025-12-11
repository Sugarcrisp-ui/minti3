#!/bin/bash
# installi3lockcolor.sh – your custom blur lock screen (2025 final)

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

USER_HOME=$(eval echo ~$USER)
REPO_DIR="$USER_HOME/github-repos/i3lock-color"
LOG_DIR="$USER_HOME/log-files/install-i3lock-color"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-i3lock-color-$TIMESTAMP.txt"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Install build dependencies once
echo "Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git autoconf automake pkg-config \
    libpam0g-dev libcairo2-dev libfontconfig1-dev \
    libxcb-composite0-dev libev-dev libx11-xcb-dev \
    libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
    libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev \
    libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev libgif-dev

# Clone or update repo
if [ -d "$REPO_DIR/.git" ]; then
    echo "Updating existing i3lock-color repo..."
    cd "$REPO_DIR"
    git pull --ff-only
else
    echo "Cloning i3lock-color repo..."
    git clone https://github.com/Raymo111/i3lock-color.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Build & install
echo "Building i3lock-color..."
autoreconf -fi
./configure --prefix=/usr --sysconfdir=/etc
make -j"$(nproc)"
sudo make install

# Final verification
if command -v i3lock-color >/dev/null 2>&1; then
    echo "SUCCESS: i3lock-color installed → $(i3lock-color --version 2>&1 | head -n1)"
else
    echo "ERROR: i3lock-color failed to install"
    exit 1
fi

echo "i3lock-color installation complete."
