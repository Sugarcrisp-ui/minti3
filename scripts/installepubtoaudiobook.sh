#!/bin/bash
# installepubtoaudiobook.sh – FINAL 2025-12-12 – NEVER asks for credentials again

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"

echo "Installing epub_to_audiobook – 100% clean, no credential prompt ever"

# NUCLEAR CLEAN: delete any old version with bad config
rm -rf "$REPO_DIR"

# Fresh clone from the public repo
git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"

# Force-disable any credential helper for this repo (prevents future prompts)
git -C "$REPO_DIR" config credential.helper ""

# Install Python deps
pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"

# Make executable
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook installed – ready"
echo "Run with: ~/github-repos/epub_to_audiobook/main.py"
