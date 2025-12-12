#!/bin/bash
# installepubtoaudiobook.sh – FINAL 2025-12-12 – deletes old repo, no credential prompt EVER

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"

echo "Installing epub_to_audiobook – 100% clean, no prompt"

# This is the ONLY thing that works: delete any old version with cached credentials
rm -rf "$REPO_DIR"

# Fresh public clone
git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"

# Install deps
pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"

# Make executable
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook installed – ready"
