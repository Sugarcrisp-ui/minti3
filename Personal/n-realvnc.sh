#!/bin/bash
set -e

# Set the home directory explicitly
HOME_DIR="/home/brett"

# Define the source and destination paths
SOURCE_DIR="$HOME_DIR/minti3/personal-settings"
DEST_DIR="/"

# List of files to copy
FILES=("etc/rc.local" "etc/vconsole.conf" "usr/share/gvfs/mounts/network.mount")
CRON_DIR="var/spool/cron"

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
        DEST_CRON_FILE="$DEST_DIR/$CRON_DIR/crontabs/$user"
        sudo cp "$CRON_FILE" "$DEST_CRON_FILE"
        sudo chown "$user:$user" "$DEST_CRON_FILE"
        sudo chmod 600 "$DEST_CRON_FILE"
    fi
done

# Copy network.mount file with root ownership and permissions
NETWORK_MOUNT_SOURCE="$SOURCE_DIR/usr/share/gvfs/mounts/network.mount"
NETWORK_MOUNT_DEST="$DEST_DIR/usr/share/gvfs/mounts/network.mount"
sudo cp "$NETWORK_MOUNT_SOURCE" "$NETWORK_MOUNT_DEST"
sudo chown root:root "$NETWORK_MOUNT_DEST"
sudo chmod 644 "$NETWORK_MOUNT_DEST"

# Create personal directory with brett ownership and permissions
PERSONAL_DIR="$DEST_DIR/personal"
sudo mkdir -p "$PERSONAL_DIR"
sudo chown brett:brett "$PERSONAL_DIR"
sudo chmod 755 "$PERSONAL_DIR"

# Create .config and .local directories with brett ownership and permissions
sudo mkdir -p "$PERSONAL_DIR/.config"
sudo chown brett:brett "$PERSONAL_DIR/.config"
sudo chmod 700 "$PERSONAL_DIR/.config"

sudo mkdir -p "$PERSONAL_DIR/.local"
sudo chown brett:brett "$PERSONAL_DIR/.local"
sudo chmod 700 "$PERSONAL_DIR/.local"

echo "Successfully Copied."
