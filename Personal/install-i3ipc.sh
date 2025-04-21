#!/bin/bash

# Script to install i3ipc in a virtual environment and set up cron job for updates on Linux Mint

# Variables
VENV_DIR="$HOME/i3ipc-venv"
CRON_JOB="# Update i3ipc every Sunday at 9:10 PM\n10 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-i3ipc.sh >> /home/brett/minti3/Personal/i3ipc-update.log 2>&1"
CRONTAB_FILE="/tmp/crontab.tmp"
USER="brett"

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y python3-venv python3-pip

# Create and set up virtual environment
echo "Creating virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment and install i3ipc
echo "Installing i3ipc..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install i3ipc
deactivate

# Verify installation
if "$VENV_DIR/bin/pip" show i3ipc >/dev/null; then
    echo "i3ipc installed successfully"
else
    echo "Error: i3ipc installation failed"
    exit 1
fi

# Set up cron job for updates
echo "Setting up cron job to update i3ipc at 9:10 PM on Sundays..."
sudo -u "$USER" crontab -l > "$CRONTAB_FILE" 2>/dev/null || touch "$CRONTAB_FILE"
if ! grep -Fx "$CRON_JOB" "$CRONTAB_FILE" >/dev/null; then
    echo -e "$CRON_JOB" >> "$CRONTAB_FILE"
    sudo -u "$USER" crontab "$CRONTAB_FILE"
    if [ $? -eq 0 ]; then
        echo "Cron job added successfully"
    else
        echo "Error: Failed to add cron job"
        exit 1
    fi
else
    echo "Cron job already exists"
fi

# Clean up
echo "Cleaning up..."
rm -f "$CRONTAB_FILE"

echo "i3ipc installation and cron job setup complete."