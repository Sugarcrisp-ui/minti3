#!/bin/bash
# installepubtoaudiobook.sh – FINAL – PUBLIC REPO THAT NEVER ASKS FOR CREDENTIALS

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"

echo "Installing epub_to_audiobook – 100% public repo, no login ever"

# Force the correct public URL (this repo is public, no auth needed)
if [ -d "$REPO_DIR" ]; then
    echo "Fixing remote URL to public..."
    (cd "$REPO_DIR" && git remote set-url origin https://github.com/p0n1/epub_to_audiobook.git)
    (cd "$REPO_DIR" && git pull --ff-only)
else
    echo "Cloning public repo..."
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"
fi

# Install deps
pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"

# Correct binary
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook installed – run with ~/github-repos/epub_to_audiobook/main.py"
