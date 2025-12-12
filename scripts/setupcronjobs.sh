#!/bin/bash
# setupcronjobs.sh – 2025-12-12 FINAL: only runs on desktop (skips on laptop)

set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Error: Do not run as root"; exit 1; }

# Detect if we're on the laptop (ThinkPad T14) – change hostname if yours is different
CURRENT_HOSTNAME=$(hostname)

if [[ "$CURRENT_HOSTNAME" == *"thinkpad-t14"* ]] || [[ "$CURRENT_HOSTNAME" == "t14"* ]]; then
    echo "Laptop detected ($CURRENT_HOSTNAME) – skipping cron jobs (only for desktop)"
    exit 0
fi

# Only runs on desktop
echo "Desktop detected – setting up cron jobs from backup..."

# Your existing cron restore logic here (unchanged)
CONFIG_SRC="/media/$USER/backup2/ULTIMATE-2025-12-11"  # or whatever path your install.sh uses

if [ -f "$CONFIG_SRC/user/cron/brett.cron" ]; then
    crontab "$CONFIG_SRC/user/cron/brett.cron"
    echo "User crontab restored"
fi

if [ -f "$CONFIG_SRC/root/cron/root.cron" ]; then
    sudo crontab "$CONFIG_SRC/root/cron/root.cron"
    echo "Root crontab restored"
fi

echo "Cron jobs installed (desktop only)"
