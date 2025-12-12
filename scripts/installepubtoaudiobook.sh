#!/bin/bash
# installepubtoaudiobook.sh – 2025-12-12 FINAL: public clone + pip + correct path

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-epub"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-epub-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing epub_to_audiobook – public HTTPS clone, no auth, no pip errors"

# Install pip if missing (Mint doesn't have it by default)
if ! command -v pip3 >/dev/null 2>&1; then
    echo "Installing python3-pip..."
    sudo apt-get update
    sudo apt-get install -y python3-pip
fi

# Clone/update the public repo (no SSH, no credentials ever)
if [ ! -d "$USER_HOME/epub_to_audiobook" ]; then
    echo "Cloning epub_to_audiobook (public HTTPS)..."
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$USER_HOME/epub_to_audiobook"
else
    echo "Updating existing epub_to_audiobook repo..."
    (cd "$USER_HOME/epub_to_audiobook" && git pull --ff-only)
fi

# Install Python dependencies (user install – safe & idempotent)
echo "Installing Python requirements..."
pip3 install --user -r "$USER_HOME/epub_to_audiobook/requirements.txt"

# Make the script executable
chmod +x "$USER_HOME/epub_to_audiobook/epub_to_audiobook.py"

echo "epub_to_audiobook installed and ready"
echo "Run with: ~/epub_to_audiobook/epub_to_audiobook.py [options]"
