#!/bin/bash
# installepubtoaudiobook.sh – 2025-12-12 FINAL: HTTPS clone of public repo (no credentials, no SSH)

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-epub"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-epub-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing epub_to_audiobook (public HTTPS clone – no auth needed)..."

# Public HTTPS clone (original repo is public – no prompt ever)
if [ ! -d "$USER_HOME/epub_to_audiobook" ]; then
    git clone --depth 1 https://github.com/p0n1/epub_to_audiobook.git "$USER_HOME/epub_to_audiobook"
else
    echo "Already exists – pulling latest"
    (cd "$USER_HOME/epub_to_audiobook" && git pull)
fi

# Dependencies + make executable
pip3 install --user -r "$USER_HOME/epub_to_audiobook/requirements.txt" || echo "Pip deps skipped (manual later if needed)"
chmod +x "$USER_HOME/epub_to_audiobook/epub_to_audiobook.py"

echo "epub_to_audiobook ready – run with ~/epub_to_audiobook/epub_to_audiobook.py [options]"
