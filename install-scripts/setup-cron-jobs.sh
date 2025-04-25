#!/bin/bash

# Script to set up cron jobs for i3 setup

# Variables
USER="brett"
USER_HOME="/home/$USER"

# Backup file for existing crontab
CRONTAB_BACKUP="$USER_HOME/crontab-backup-$(date +%F-%H%M%S).txt"

# Backup current crontab
crontab -l > "$CRONTAB_BACKUP"
echo "Current crontab backed up to $CRONTAB_BACKUP"

# Define cron jobs
CRON_JOBS=(
    "10 21 * * 0 /bin/bash $USER_HOME/minti3/Personal/update-i3ipc.sh >> $USER_HOME/minti3/Personal/i3ipc-update.log 2>&1 # Update i3ipc every Sunday at 9:10 PM"
    "20 21 * * 0 /bin/bash $USER_HOME/minti3/Personal/update-i3lock-color.sh >> $USER_HOME/minti3/Personal/i3lock-color-update.log 2>&1 # Update i3lock-color every Sunday at 9:20 PM"
    "0 23 * * * /bin/bash $USER_HOME/.bin-personal/backup-dotfiles.sh # Run backup-dotfiles.sh to backup personal settings daily at 23:00"
)

# Write cron jobs to a temporary file
TEMP_CRON_FILE=$(mktemp)
for job in "${CRON_JOBS[@]}"; do
    echo "$job" >> "$TEMP_CRON_FILE"
done

# Apply the new crontab
crontab "$TEMP_CRON_FILE"
rm "$TEMP_CRON_FILE"

# Verify the crontab
echo "Updated crontab:"
crontab -l

echo "Cron jobs setup completed."