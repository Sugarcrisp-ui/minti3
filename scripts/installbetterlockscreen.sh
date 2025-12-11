#!/bin/bash
# installbetterlockscreen.sh – 2025 final: your Tesla lock screen

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO="$USER_HOME/github-repos/betterlockscreen"
LOG_DIR="$USER_HOME/log-files/install-betterlockscreen"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-betterlockscreen-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing betterlockscreen (your Tesla Model S lock screen)..."

# Only the 4 packages you actually need
sudo apt-get install -y --no-install-recommends \
    bc imagemagick feh i3lock-color

# Clone your fork (you have custom changes)
if [[ -d "$REPO/.git" ]]; then
    git -C "$REPO" pull --ff-only
else
    git clone https://github.com/Sugarcrisp-ui/betterlockscreen.git "$REPO"
fi

# Install system-wide
cd "$REPO"
sudo bash install.sh system

echo "betterlockscreen installed → lock-screen.sh works perfectly"
