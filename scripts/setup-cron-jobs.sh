#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
CRONTAB_BACKUP="$USER_HOME/crontab-backup-$(date +%F-%H%M%S).txt"

# Check for cron
echo "Checking for cron..."
if ! dpkg -l | grep -q " cron "; then
    echo "Installing cron..."
    sudo apt-get install -y cron
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install cron. Exiting."
        exit 1
    fi
else
    echo "cron is already installed."
fi

# Ensure crontab command is available
if ! command -v crontab >/dev/null 2>&1; then
    echo "Error: crontab command not found. Exiting."
    exit 1
fi

# Backup current crontab
echo "Backing up current crontab to $CRONTAB_BACKUP..."
crontab -l > "$CRONTAB_BACKUP" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Warning: No existing crontab found. Creating new crontab."
    touch "$CRONTAB_BACKUP"
fi

# Define cron jobs
CRON_JOBS=(
    "10 21 * * 0 /bin/bash $USER_HOME/minti3/Personal/update-i3ipc.sh >> $USER_HOME/minti3/Personal/i3ipc-update.log 2>&1 # Update i3ipc every Sunday at 9:10 PM"
    "20 21 * * 0 /bin/bash $USER_HOME/minti3/Personal/update-i3lock-color.sh >> $USER_HOME/minti3/Personal/i3ipc-update.log 2>&1 # Update i3lock-color every Sunday at 9:20 PM"
    "0 23 * * * /bin/bash $USER_HOME/.bin-personal/backup-dotfiles.sh # Run backup-dotfiles.sh to backup personal settings daily at 23:00"
)

# Write cron jobs to a temporary file
echo "Writing cron jobs to temporary file..."
TEMP_CRON_FILE=$(mktemp)
if [ $? -ne 0 ]; then
    echo "Error: Failed to create temporary file. Exiting."
    exit 1
fi
for job in "${CRON_JOBS[@]}"; do
    echo "$job" >> "$TEMP_CRON_FILE"
done

# Apply the new crontab
echo "Applying new crontab..."
crontab "$TEMP_CRON_FILE"
if [ $? -ne 0 ]; then
    echo "Error: Failed to apply new crontab. Exiting."
    rm -f "$TEMP_CRON_FILE"
    exit 1
fi
rm -f "$TEMP_CRON_FILE"

# Verify the crontab
echo "Verifying crontab..."
CRONTAB_CONTENT=$(crontab -l 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve crontab. Exiting."
    exit 1
fi
for job in "${CRON_JOBS[@]}"; do
    # Match the schedule and command (excluding comment)
    job_pattern=$(echo "$job" | cut -d'#' -f1 | sed 's/[ \t]*$//')
    if echo "$CRONTAB_CONTENT" | grep -qF "$job_pattern"; then
        echo "Cron job verified: $(echo "$job" | cut -d'#' -f2-)"
    else
        echo "Warning: Cron job not found in crontab: $(echo "$job" | cut -d'#' -f2-)"
    fi
done
echo "Updated crontab:"
echo "$CRONTAB_CONTENT"

echo "Cron jobs setup completed."
