#!/bin/bash

# Script to set up all cron jobs for i3 setup on Linux Mint

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
USER="brett"
CRONTAB_FILE="/tmp/crontab.$USER.tmp"

# Define all cron jobs
CRON_JOBS=(
    "# Update i3ipc every Sunday at 9:10 PM\n10 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-i3ipc.sh >> /home/brett/minti3/Personal/i3ipc-update.log 2>&1"
    "# Update i3lock-color every Sunday at 9:20 PM\n20 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-i3lock-color.sh >> /home/brett/minti3/Personal/i3lock-color-update.log 2>&1"
    "# Update GitHub Desktop every Sunday at 9:00 PM\n0 21 * * 0 /bin/bash /home/brett/minti3/Personal/update-github-desktop.sh >> /home/brett/minti3/Personal/github-desktop-update.log 2>&1"
)

# Clear existing cron jobs for this user
sudo -u "$USER" crontab -r 2>/dev/null || true

# Set up new cron jobs
sudo -u "$USER" crontab -l > "$CRONTAB_FILE" 2>/dev/null || touch "$CRONTAB_FILE"
for job in "${CRON_JOBS[@]}"; do
    echo -e "$job" >> "$CRONTAB_FILE"
done
sudo -u "$USER" crontab "$CRONTAB_FILE"
if [ $? -eq 0 ]; then
    echo "Cron jobs set up successfully"
else
    echo "Error: Failed to set up cron jobs"
    exit 1
fi

# Clean up
rm -f "$CRONTAB_FILE"

echo "Cron job setup complete."
