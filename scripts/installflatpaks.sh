#!/bin/bash
# installepubtoaudiobook.sh – FINAL: public HTTPS clone (no credentials ever)

set -euo pipefail

REPO_DIR="$HOME/github-repos/epub_to_audiobook"

if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning epub_to_audiobook (public HTTPS)..."
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$REPO_DIR"
else
    echo "Updating epub_to_audiobook..."
    (cd "$REPO_DIR" && git pull --ff-only)
fi

pip3 install --user --break-system-packages -r "$REPO_DIR/requirements.txt"
chmod +x "$REPO_DIR/main.py"

echo "epub_to_audiobook ready"
