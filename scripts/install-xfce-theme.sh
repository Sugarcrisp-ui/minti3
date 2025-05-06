#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-xfce-theme"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-xfce-theme-$TIMESTAMP.txt"
LATEST_LOG="$LOG_DIR/install-xfce-theme-output.txt"

# Redirect output to timestamped and latest log files
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE" "$LATEST_LOG") 2>&1
echo "Logging output to $OUTPUT_FILE and $LATEST_LOG"

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    arc-theme
    xfce4-settings
)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Apply Arc-Darker GTK theme
echo "Applying Arc-Darker GTK theme..."
if command -v xfconf-query >/dev/null; then
    xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Set GTK theme to Arc-Darker."
    else
        echo "Warning: Failed to set GTK theme to Arc-Darker."
    fi
else
    echo "Warning: xfconf-query not found. Skipping theme application."
fi

# Verify theme application
echo "Verifying theme application..."
if xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null | grep -q "Arc-Darker"; then
    echo "Arc-Darker GTK theme applied successfully."
else
    echo "Warning: Arc-Darker GTK theme not applied."
fi

echo "XFCE theme installation complete."
