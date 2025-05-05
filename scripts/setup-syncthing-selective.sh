#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
USER_HOME=$(eval echo ~$USER)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
LOG_DIR="$USER_HOME/log-files/setup-syncthing-selective"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/setup-syncthing-selective-$TIMESTAMP.txt"
LATEST_LOG="$LOG_DIR/setup-syncthing-selective-output.txt"

# Redirect output to file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE" "$LATEST_LOG") 2>&1
echo "Logging output to $OUTPUT_FILE and $LATEST_LOG"

# Install Syncthing if not already installed
if ! command -v syncthing >/dev/null 2>&1; then
    echo "Installing Syncthing..."
    sudo apt update
    sudo apt install -y syncthing
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to install Syncthing. Continuing."
    fi
else
    echo "Syncthing already installed."
fi

# Start Syncthing for the current user
echo "Starting Syncthing for user $USER..."
systemctl --user enable syncthing.service 2>/dev/null
systemctl --user start syncthing.service 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Warning: Failed to start Syncthing service. Continuing."
fi

# Wait for Syncthing to initialize
sleep 5

# Create a dedicated folder for Syncthing config syncing
echo "Creating ~/syncthing-configs/ for selective syncing..."
mkdir -p ~/syncthing-configs
if [ $? -ne 0 ]; then
    echo "Warning: Failed to create ~/syncthing-configs/. Continuing."
fi

# Verify Syncthing is running
echo "Verifying Syncthing service..."
if systemctl --user is-active syncthing.service >/dev/null; then
    echo "Syncthing is running."
else
    echo "Warning: Syncthing service is not running."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Syncthing functionality may be restricted."
fi

# Output instructions
echo "Syncthing setup complete."
echo "Access the Syncthing web GUI at http://localhost:8384 to pair devices."
echo "After pairing, select config files to sync into ~/syncthing-configs/."
echo "Check Syncthing status with 'systemctl --user status syncthing.service' if needed."
