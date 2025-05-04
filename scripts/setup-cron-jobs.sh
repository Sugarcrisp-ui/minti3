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
OUTPUT_FILE="/home/brett/log-files/setup-cron-jobs/setup-cron-jobs-output.txt"

# Redirect output to file
mkdir -p ~/log-files/setup-cron-jobs
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check for cron
echo "Checking for cron..."
if ! dpkg -l | grep -q " cron "; then
    echo "Installing cron..."
    sudo apt-get install -y cron
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to install cron. Continuing."
    fi
else
    echo "cron is already installed."
fi

# Ensure crontab command is available
if ! command -v crontab >/dev/null 2>&1; then
    echo "Warning: crontab command not found. Cron jobs may not be applied."
fi

# Backup current crontab
echo "Backing up current crontab to $CRONTAB_BACKUP..."
crontab -l > "$CRONTAB_BACKUP" 2>/dev/null || touch "$CRONTAB_BACKUP"
echo "Backup created at $CRONTAB_BACKUP."

# Define cron jobs
CRON_JOBS=(
    "# Update i3lock-color every Sunday at 9:20 PM"
    "20 21 * * 0 /bin/bash $USER_HOME/github-repos/minti3/scripts/install-i3lock-color.sh >> $USER_HOME/log-files/install-i3lock-color/install-i3lock-color.log 2>&1"
    "# Backup user config files to user-configs repo daily at 22:00"
    "0 22 * * * /bin/bash $USER_HOME/.bin-personal/backup-user-configs-github-rsync.sh >> $USER_HOME/log-files/backup-user-configs-github-rsync/backup-user-configs-github-rsync.log 2>&1"
    "# Backup user config files to external daily at 22:10"
    "10 22 * * * /bin/bash $USER_HOME/.bin-personal/backup-user-configs-external-rsync.sh >> $USER_HOME/log-files/backup-user-configs-external-rsync/backup-user-configs-external-rsync.log 2>&1"
)

# Write cron jobs to a temporary file
echo "Writing cron jobs to temporary file..."
TEMP_CRON_FILE=$(mktemp)
if [ $? -ne 0 ]; then
    echo "Warning: Failed to create temporary file. Cron jobs may not be applied."
else
    for job in "${CRON_JOBS[@]}"; do
        echo "$job" >> "$TEMP_CRON_FILE"
    done

    # Apply the new crontab
    echo "Applying new crontab..."
    crontab "$TEMP_CRON_FILE"
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to apply new crontab."
    fi
    rm -f "$TEMP_CRON_FILE"
fi

# Verify the crontab
echo "Verifying crontab..."
CRONTAB_CONTENT=$(crontab -l 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "Warning: Failed to retrieve crontab."
else
    for job in "${CRON_JOBS[@]}"; do
        job_pattern=$(echo "$job" | cut -d'#' -f1 | sed 's/[ \t]*$//')
        if echo "$CRONTAB_CONTENT" | grep -qF "$job_pattern"; then
            echo "Cron job verified: $(echo "$job" | cut -d'#' -f2-)"
        else
            echo "Warning: Cron job not found: $(echo "$job" | cut -d'#' -f2-)"
        fi
    done
    echo "Updated crontab:"
    echo "$CRONTAB_CONTENT"
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Cron functionality may be restricted."
fi

echo "Cron jobs setup completed."
