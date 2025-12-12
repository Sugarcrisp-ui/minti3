#!/bin/bash
# installepubtoaudiobook.sh – 2025-12-12 FINAL: public repo, no credentials EVER

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"

echo "Installing epub_to_audiobook – public repo, no login"

# Clone or update using the PUBLIC HTTPS URL
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning public epub_to_audiobook repo..."
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"
else
    echo "Updating epub_to_audiobook repo..."
    (cd "$REPO_DIR" && git remote set-url origin https://github.com/p0n1/epub_to_audiobook.git)
    (cd "$REPO_DIR" && git pull --ff-only)
fi

# Install deps
pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"

# Make executable
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook installed – run with ~/github-repos/epub_to_audiobook/main.py"
