#!/bin/bash

# Script to install and configure Syncthing for selective config file syncing
# Run on both Desktop Brett and Laptop Brett

# Exit on error
set -e

# Install Syncthing if not already installed
if ! command -v syncthing &> /dev/null; then
    echo "Installing Syncthing..."
    sudo apt update
    sudo apt install -y syncthing
else
    echo "Syncthing already installed."
fi

# Start Syncthing for the current user
echo "Starting Syncthing for user $USER..."
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# Wait for Syncthing to initialize (web GUI starts on port 8384)
sleep 5

# Create a dedicated folder for Syncthing config syncing
echo "Creating ~/syncthing-configs/ for selective syncing..."
mkdir -p ~/syncthing-configs

# Output instructions for next steps
echo "Syncthing installed and running."
echo "Access the Syncthing web GUI at http://localhost:8384 to pair devices."
echo "After pairing, you will select specific config files to sync into ~/syncthing-configs/."
echo "Verify Syncthing is running with 'systemctl --user status syncthing.service' if needed."
