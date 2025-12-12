#!/bin/bash
# installepubtoaudiobook.sh – FINAL 2025-12-12: PUBLIC HTTPS ONLY – NO CREDENTIAL PROMPT EVER

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-epub"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-epub-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing epub_to_audiobook – PUBLIC HTTPS (no credentials)"

REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning public repo..."
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"
else
    echo "Updating repo..."
    (cd "$REPO_DIR" && git pull --ff-only)
fi

# Install deps (safe for Mint 22.1)
pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"

# Correct binary
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook ready – run with ~/github-repos/epub_to_audiobook/main.py"
