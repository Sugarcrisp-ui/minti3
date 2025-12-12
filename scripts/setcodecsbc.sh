#!/bin/bash
# setcodecsbc.sh – 2025-12-12 FINAL: Mint 22.1 codec pack

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

LOG_DIR="$HOME/log-files/install-codecs"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-codecs-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing Mint codec pack (H.264, fonts, etc.)..."

# Mint 22.1 equivalent of ubuntu-restricted-extras
sudo apt-get update
sudo apt-get install -y mint-meta-codecs

# Extra fonts most people want
sudo apt-get install -y fonts-crosextra-carlito fonts-crosextra-caladea

echo "Codecs and fonts installed – YouTube, Netflix, etc. ready"
