#!/bin/bash
# installepubtoaudiobook.sh – 2025 final: your PDF→audiobook converter

set -euo pipefail

USER_HOME="${HOME:?}"
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"
VENV_DIR="$USER_HOME/.local/venv/epub-to-audiobook"
LOG_DIR="$USER_HOME/log-files/install-epub-to-audiobook"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-epub-to-audiobook-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing epub_to_audiobook (PDF/EPUB → audiobook with Piper TTS)..."

# Clone or update repo
if [[ -d "$REPO_DIR/.git" ]]; then
    echo "Updating epub_to_audiobook repo..."
    git -C "$REPO_DIR" pull --ff-only
else
    echo "Cloning epub_to_audiobook repo..."
    git clone https://github.com/brettcrisp2/epub_to_audiobook.git "$REPO_DIR"
fi

# Dedicated venv (no conflict with i3ipc)
python3 -m venv "$VENV_DIR" 2>/dev/null || true
# shellcheck source=/dev/null
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$REPO_DIR/requirements.txt"

# Rofi launcher
LAUNCHER="$USER_HOME/.local/share/applications/epub-to-audiobook.desktop"
cat > "$LAUNCHER" <<EOF
[Desktop Entry]
Name=EPUB to Audiobook
Comment=Convert PDF/EPUB to audiobook with Piper TTS
Exec=$VENV_DIR/bin/python $REPO_DIR/main.py
Icon=audio-x-generic
Terminal=true
Type=Application
Categories=Utility;Audio;
EOF

echo "epub_to_audiobook ready → search 'EPUB to Audiobook' in Rofi"
