#!/bin/bash
set -e

# Define the source and destination paths
SOURCE_DIR=~/minti3/personal-settings
DEST_DIR=/etc

# List of files and directories to copy
FILES=("rc.local" "vconsole.conf" "usr/share/gvfs/mounts/network.mount")
CRON_DIR="var/spool/cron"
NEW_DIR="/personal"

# Copy files and set permissions
for item in "${FILES[@]}"; do
    SOURCE_PATH="$SOURCE_DIR/$item"
    DEST_PATH="$DEST_DIR/$item"

    # Create directory structure if it doesn't exist
    sudo mkdir -p "$(dirname "$DEST_PATH")"

    # Copy file and set permissions
    sudo cp "$SOURCE_PATH" "$DEST_PATH"
    sudo chown root:root "$DEST_PATH"
    sudo chmod 644 "$DEST_PATH"
done

# Copy cron files if they exist
for user in "brett" "root"; do
    CRON_FILE="$SOURCE_DIR/$CRON_DIR/$user"
    if [ -e "$CRON_FILE" ]; then
        DEST_CRON_FILE="$DEST_DIR/$CRON_DIR/$user"
        sudo cp "$CRON_FILE" "$DEST_CRON_FILE"
        sudo chown "$user:$user" "$DEST_CRON_FILE"
        sudo chmod 600 "$DEST_CRON_FILE"
    fi
done

# Create /personal/ directory and subdirectories
sudo mkdir -p "/$NEW_DIR/.config"
sudo mkdir -p "/$NEW_DIR/.local"

# Set ownership and permissions for /personal/ directory
sudo chown "$USER:$USER" "/$NEW_DIR"
sudo chmod 755 "/$NEW_DIR"

# Set ownership and permissions for /personal/.config/ and /personal/.local/
sudo chown -R "$USER:$USER" "/$NEW_DIR/.config" "/$NEW_DIR/.local"
sudo chmod -R 700 "/$NEW_DIR/.config" "/$NEW_DIR/.local"

echo "Personal settings copied to /etc successfully."
