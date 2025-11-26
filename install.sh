#!/bin/bash
# install.sh – minti3 full system setup + restore (2025 FINAL – perfect forever)

USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

USER_HOME=$(eval echo ~$USER)
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"

# Logging
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "=== minti3 install started: $TIMESTAMP ==="

# Cache sudo
echo "Caching sudo credentials..."
sudo -v || exit 1

# Clone minti3 repo if missing
if [ ! -d "$GITHUB_REPOS_DIR/minti3" ]; then
    echo "Cloning minti3 install scripts from GitHub..."
    mkdir -p "$GITHUB_REPOS_DIR"
    git clone https://github.com/Sugarcrisp-ui/minti3.git "$GITHUB_REPOS_DIR/minti3"
fi
cd "$GITHUB_REPOS_DIR/minti3" || exit 1

# === CRITICAL: Require external backup drive ===
if [ ! -d "/media/$USER/backup" ]; then
    echo "ERROR: External LUKS backup drive not found!"
    echo "       Plug in your drive and re-run this script."
    exit 1
fi

# Find the newest ULTIMATE backup (no symlink dependency)
LATEST_BACKUP=$(ls -1d /media/$USER/backup/ULTIMATE-* 2>/dev/null | sort | tail -1)
if [ -z "$LATEST_BACKUP" ]; then
    echo "ERROR: No ULTIMATE backup found on external drive!"
    echo "       Run ultimate-backup.sh first."
    exit 1
fi

CONFIG_SRC="$LATEST_BACKUP"
echo "Found latest backup → $CONFIG_SRC"
echo "Starting FULL perfect restore..."

# Mount external LUKS drive (if not already)
if ! mount | grep -q "/media/$USER/backup"; then
    echo "Mounting external LUKS drive..."
    bash "$SCRIPTS_DIR/automount-external-luks.sh" || exit 1
fi

# Run all install scripts
scripts=(
    "install-i3-mint.sh"
    "install-i3-apps.sh"
    "install-flatpaks.sh"
    "install-docker-services.sh"
    "install-epub-to-audiobook.sh"
    "install-i3lock-color.sh"
    "install-betterlockscreen.sh"
    "install-i3-logout.sh"
    "install-autotiling.sh"
    "install-sddm-simplicity.sh"
    "install-xfce-theme.sh"
    "install-realvnc.sh"
    "setup-cron-jobs.sh"
    "update-i3ipc.sh"
    "set-dpi.sh"
    "set-codec-sbc.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        echo "Running $script..."
        bash "$SCRIPTS_DIR/$script" || echo "Warning: $script failed"
    else
        echo "Warning: $script not found — skipping"
    fi
done

# Restore user configs from latest backup
echo "Restoring user configurations from latest backup..."
config_mappings=(
    ".config/brave-profiles:$USER_HOME/.config/brave-profiles"
    ".mozilla:$USER_HOME/.mozilla"
    ".ssh:$USER_HOME/.ssh"
    ".vscode:$USER_HOME/.vscode"
    "Notebooks:$USER_HOME/Notebooks"
    "protonvpn-server-configs:$USER_HOME/protonvpn-server-configs"
    "sddm.conf:/etc/sddm.conf"
    "sudoers:/etc/sudoers"
)

for mapping in "${config_mappings[@]}"; do
    src="${mapping%%:*}"
    dest="${mapping##*:}"
    src_path="$CONFIG_SRC/user/home/brett/$src"
    if [ -e "$src_path" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -rf "$src_path" "$dest"
        echo "Restored $src → $dest"
    fi
done

# Restore crontabs
[ -f "$CONFIG_SRC/user/cron/brett.cron" ] && crontab "$CONFIG_SRC/user/cron/brett.cron" && echo "User crontab restored"
[ -f "$CONFIG_SRC/root/cron/root.cron" ] && sudo crontab "$CONFIG_SRC/root/cron/root.cron" && echo "Root crontab restored"

echo "=== minti3 installation + full restore complete! ==="
echo "Reboot and enjoy your perfect i3 desktop."

echo "------------------------------------------------------------"
echo "FINAL STEP AFTER REBOOT:"
echo "   Run once (or add to i3 config):"
echo "       eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
echo "   This loads your SSH key for GitHub (already restored from backup)"
echo "------------------------------------------------------------"
