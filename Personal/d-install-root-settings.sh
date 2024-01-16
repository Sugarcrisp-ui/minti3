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

# Function to copy files with specified ownership and permissions
copy_file() {
    local source_path="$1"
    local dest_path="$2"
    sudo mkdir -p "$(dirname "$dest_path")"
    sudo cp "$source_path" "$dest_path"
    sudo chown root:root "$dest_path"
    sudo chmod 644 "$dest_path"
}

# Copy files and set permissions
for item in "${FILES[@]}"; do
    SOURCE_PATH="$SOURCE_DIR/$item"
    DEST_PATH="$DEST_DIR/$item"
    copy_file "$SOURCE_PATH" "$DEST_PATH"
done

# Copy cron files if they exist
for user in "brett" "root"; do
    CRON_FILE="$SOURCE_DIR/$CRON_DIR/$user"
    if [ -e "$CRON_FILE" ]; then
        DEST_CRON_FILE="$DEST_DIR/$CRON_DIR/crontabs/$user"
        copy_file "$CRON_FILE" "$DEST_CRON_FILE"
        sudo chown "$user:$user" "$DEST_CRON_FILE"
        sudo chmod 600 "$DEST_CRON_FILE"
    fi
done

# Copy network.mount file with root ownership and permissions
NETWORK_MOUNT_SOURCE="$SOURCE_DIR/usr/share/gvfs/mounts/network.mount"
NETWORK_MOUNT_DEST="$DEST_DIR/usr/share/gvfs/mounts/network.mount"
copy_file "$NETWORK_MOUNT_SOURCE" "$NETWORK_MOUNT_DEST"

# Create personal directory with brett ownership and permissions
PERSONAL_DIR="$DEST_DIR/personal"
sudo mkdir -p "$PERSONAL_DIR"
sudo chown brett:brett "$PERSONAL_DIR"
sudo chmod 755 "$PERSONAL_DIR"

# Create .config and .local directories with brett ownership and permissions
for sub_dir in ".config" ".local"; do
    SUB_DIR_PATH="$PERSONAL_DIR/$sub_dir"
    sudo mkdir -p "$SUB_DIR_PATH"
    sudo chown brett:brett "$SUB_DIR_PATH"
    sudo chmod 700 "$SUB_DIR_PATH"
done

echo "Personal settings copied to the root directory successfully."
