#!/bin/bash
# installautotiling.sh – 2025 final: minimal, fast, bullet-proof

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
VENV="$USER_HOME/i3ipc-venv"
BIN="$USER_HOME/.bin-personal"
REPO="$USER_HOME/autotiling"
LOG_DIR="$USER_HOME/log-files/install-autotiling"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-autotiling-$(date +%Y%m%d-%H%M%S).txt") 2>&1

echo "Installing autotiling (golden-ratio split)..."

# Dependencies + venv in one shot
sudo apt-get install -y --no-install-recommends git python3 python3-pip python3-venv

# venv + i3ipc
python3 -m venv "$VENV"
# shellcheck source=/dev/null
source "$VENV/bin/activate"
pip install --upgrade pip
pip install i3ipc
deactivate

# Clone / update repo
if [[ -d "$REPO/.git" ]]; then
    git -C "$REPO" pull --ff-only
else
    git clone https://github.com/nwg-piotr/autotiling.git "$REPO"
fi

# Install binary
mkdir -p "$BIN"
cp "$REPO/autotiling.py" "$BIN/autotiling"
chmod +x "$BIN/autotiling"
sed -i "1s|.*|#!$VENV/bin/python3|" "$BIN/autotiling"

# i3 config – idempotent
I3_CONFIG="$USER_HOME/.config/i3/config"
LINE='exec --no-startup-id ~/.bin-personal/autotiling'
grep -Fx "$LINE" "$I3_CONFIG" >/dev/null || echo "$LINE" >> "$I3_CONFIG"

echo "autotiling installed → golden-ratio splits active"
