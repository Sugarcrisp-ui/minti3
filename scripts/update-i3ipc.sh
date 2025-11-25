#!/bin/bash
# update-i3ipc.sh – 2025 final: keep i3ipc fresh in dedicated venv

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

VENV="${HOME:?}/i3ipc-venv"
LOG_DIR="${HOME:?}/log-files/update-i3ipc"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/update-i3ipc-$(date +%Y%m%d-%H%M%S).txt") 2>&1

[[ -d "$VENV" ]] || { echo "Error: $VENV missing"; exit 1; }

# shellcheck source=/dev/null
source "$VENV/bin/activate"

pip install --upgrade pip i3ipc

echo "i3ipc updated to $(pip show i3ipc | grep ^Version | cut -d' ' -f2)"
