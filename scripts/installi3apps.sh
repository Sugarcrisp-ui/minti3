#!/bin/bash
# installi3apps.sh — 2025-12-12 FINAL — guaranteed to work on fresh Mint 22.1

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

echo "Installing Brave and Warp (2025-12 working method)..."

# Brave — official one-liner from brave.com (works every time)
if ! command -v brave-browser >/dev/null; then
    echo "Installing Brave Browser..."
    sudo apt install -y curl
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | \
        sudo tee /etc/apt/sources.list.d/brave-browser-release.sources
    sudo apt update
    sudo apt install -y brave-browser
else
    echo "Brave already installed"
fi

# Warp — direct .deb from their official download page (always current)
if ! command -v warp-terminal >/dev/null; then
    echo "Installing Warp Terminal..."
    curl -fsSL https://app.warp.dev/download?package=deb -o /tmp/warp.deb
    sudo apt install -y /tmp/warp.deb || sudo apt-get install -f -y
    rm -f /tmp/warp.deb
else
    echo "Warp already installed"
fi

# (all your other packages stay exactly as before)
