#!/bin/bash
# install-flatpaks.sh – install only the Flatpaks you actually want

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-flatpaks"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-flatpaks-$TIMESTAMP.txt"

mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# === YOUR FLATPAK LIST (edit this only) ===
FLATPAKS=(
    "com.bitwarden.desktop"          # Bitwarden
    "io.github.PintaProject.Pinta"   # Pinta
    # Add new ones here, one per line
    # "org.signal.Signal"            # Example: uncomment to install Signal
)

echo "Installing ${#FLATPAKS[@]} approved Flatpaks..."

# Ensure Flathub is enabled
if ! flatpak remotes | grep -q "^flathub[[:space:]]"; then
    echo "Adding Flathub repository..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add Flathub. Continuing anyway."
    fi
fi

# Install each Flatpak from the list
for app_id in "${FLATPAKS[@]}"; do
    if flatpak list --app | grep -q "^$app_id[[:space:]]"; then
        echo "$app_id is already installed."
    else
        echo "Installing $app_id..."
        flatpak install -y flathub "$app_id"
        if [ $? -eq 0 ]; then
            echo "$app_id installed successfully."
        else
            echo "Error: Failed to install $app_id. Continuing."
        fi
    fi
done

echo "Flatpak installation complete."
