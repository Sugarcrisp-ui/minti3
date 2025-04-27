#!/bin/bash

# Script to set up i3lock-color update cron job in root crontab on Linux Mint

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
CRON_JOB="# Update i3lock-color every Sunday at 9:20 PM\n20 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-i3lock-color.sh >> /home/brett/minti3/Personal/i3lock-color-update.log 2>&1"
CRONTAB_FILE="/tmp/crontab.root.tmp"

# Set up cron job
echo "Setting up cron job to update i3lock-color at 9:20 PM on Sundays..."
sudo crontab -l > "$CRONTAB_FILE" 2>/dev/null || touch "$CRONTAB_FILE"
if ! grep -F "$CRON_JOB" "$CRONTAB_FILE" >/dev/null; then
    echo -e "$CRON_JOB" >> "$CRONTAB_FILE"
    sudo crontab "$CRONTAB_FILE"
    if [ $? -eq 0 ]; then
        echo "Cron job added successfully to root crontab"
    else
        echo "Error: Failed to add cron job to root crontab"
        exit 1
    fi
else
    echo "Cron job already exists in root crontab"
fi

# Clean up
rm -f "$CRONTAB_FILE"

echo "i3lock-color cron job setup complete."