#!/bin/bash
# installautotiling.sh – 2025-12-12 FINAL: correct repo + binary name autotiling

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-autotiling"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-autotiling-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing autotiling (golden-ratio split) – correct repo & binary"

# Install python3-venv if missing
sudo apt-get update
sudo apt-get install -y python3-venv

# Create virtual environment
VENV_DIR="$USER_HOME/i3ipc-venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

# Activate venv and install i3ipc
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install i3ipc python-xlib

# Clone the CORRECT repo (nwg-piotr/autotiling) – the one with binary named 'autotiling'
REPO_DIR="$USER_HOME/autotiling"
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning correct autotiling repo (nwg-piotr)..."
    git clone --depth 1 https://github.com/nwg-piotr/autotiling.git "$REPO_DIR"
else
    echo "Updating existing autotiling repo..."
    (cd "$REPO_DIR" && git pull --ff-only)
fi

# Correct binary is just called 'autotiling'
chmod +x "$REPO_DIR/autotiling"

# Symlink to ~/.local/bin so i3 can find it
mkdir -p "$USER_HOME/.local/bin"
ln -sf "$REPO_DIR/autotiling" "$USER_HOME/.local/bin/autotiling"

# Ensure ~/.local/bin is in PATH
if ! grep -q '\.local/bin' "$USER_HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.bashrc"
fi

echo "autotiling installed and ready"
echo "Add to i3 config: exec --no-startup-id autotiling"
