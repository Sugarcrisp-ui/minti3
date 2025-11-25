#!/bin/bash
# install-flatpaks.sh – 2025 final: ultra-clean, bullet-proof

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
LOG_DIR="$USER_HOME/log-files/install-flatpaks"
mkdir -p "$LOG_DIR"
exec > >(tee -a "$LOG_DIR/install-flatpaks-$(date +%Y%m%d-%H%M%S).txt") 2>&1

# === YOUR FLATPAKS (single source of truth) ===
FLATPAKS=(
    com.bitwarden.desktop          # Bitwarden
    io.github.PintaProject.Pinta   # Pinta
)

echo "Installing ${#FLATPAKS[@]} approved Flatpaks..."

# Ensure Flathub (system-wide, once)
flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install each
for app_id in "${FLATPAKS[@]}"; do
    if flatpak list --app | grep -q "^$app_id[[:space:]]"; then
        echo "✓ $app_id already installed"
    else
        echo "→ Installing $app_id..."
        flatpak install -y --system flathub "$app_id"
    fi
done

echo "Flatpak installation complete"
