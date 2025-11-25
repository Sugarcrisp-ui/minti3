#!/bin/bash
# install-epub-to-audiobook.sh – your PDF→audiobook tool

USER=$(whoami)
USER_HOME=$(eval echo ~$USER)
REPO_DIR="$USER_HOME/github-repos/epub_to_audiobook"
VENV_DIR="$USER_HOME/i3ipc-venv"   # reusing your existing venv is fine, or make a new one

echo "Installing epub_to_audiobook..."

# Clone if missing
if [ ! -d "$REPO_DIR" ]; then
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone https://github.com/yourusername/epub_to_audiobook.git "$REPO_DIR"
fi

# Create/activate venv + install deps
python3 -m venv "$VENV_DIR" 2>/dev/null || true
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$REPO_DIR/requirements.txt"  # or whatever it needs

# Desktop launcher (so you can launch from Rofi)
cat > ~/.local/share/applications/epub-to-audiobook.desktop <<EOF
[Desktop Entry]
Name=EPUB to Audiobook
Comment=Convert PDF/EPUB to audiobook with Piper TTS
Exec=$VENV_DIR/bin/python $REPO_DIR/main.py
Icon=audio-x-generic
Terminal=true
Type=Application
Categories=Utility;
EOF

echo "epub_to_audiobook ready → search 'EPUB to Audiobook' in Rofi"
