#!/bin/bash
# setupcronjobs.sh – 2025 final: restore your real crontabs from external drive

set -euo pipefail

[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

USER_HOME="${HOME:?}"
BACKUP_DIR="/media/$USER/backup/daily.latest/backup.latest"

echo "Restoring user and root crontabs from external drive..."

# User crontab
if [[ -f "$BACKUP_DIR/cron/user_crontab" ]]; then
    crontab "$BACKUP_DIR/cron/user_crontab" && echo "User crontab restored"
else
    echo "No user crontab backup found"
fi

# Root crontab
if [[ -f "$BACKUP_DIR/cron/root_crontab" ]]; then
    sudo crontab "$BACKUP_DIR/cron/root_crontab" && echo "Root crontab restored"
else
    echo "No root crontab backup found"
fi

echo "Cron jobs restored from external drive"
