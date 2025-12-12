#!/bin/bash
# install.sh – minti3 full system setup + restore (2025-12-12 FINAL – 100% clean, no more pieces)

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

# Load SSH key early for private repos
if [[ -f "$USER_HOME/.ssh/id_ed25519" ]]; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    ssh-add "$USER_HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

# Clone minti3 repo if missing
if [ ! -d "$GITHUB_REPOS_DIR/minti3" ]; then
    echo "Cloning minti3 install scripts from GitHub..."
    mkdir -p "$GITHUB_REPOS_DIR"
    git clone https://github.com/Sugarcrisp-ui/minti3.git "$GITHUB_REPOS_DIR/minti3"
fi
cd "$GITHUB_REPOS_DIR/minti3" || exit 1

# FINAL BACKUP DETECTION – works with backup OR backup2, any depth
ULTIMATE_PATH=$(find /media/$USER -maxdepth 4 -type d -name "ULTIMATE*" -print 2>/dev/null | head -n 1)

if [ -z "$ULTIMATE_PATH" ]; then
    echo "ERROR: No ULTIMATE* backup found under /media/$USER"
    echo "   Looked up to 4 levels deep in backup and backup2"
    echo "   Plug in your backup drive and re-run."
    exit 1
fi

BACKUP_ROOT=$(dirname "$ULTIMATE_PATH")
LATEST_BACKUP=$(find "$BACKUP_ROOT" -type d -name "ULTIMATE*" 2>/dev/null | sort -r | head -n 1)

CONFIG_SRC="$LATEST_BACKUP"
echo "Found backup drive → $BACKUP_ROOT"
echo "Using latest backup → $LATEST_BACKUP"

# Run all install scripts
scripts=(
    "installi3mint.sh"
    "installi3apps.sh"
    "installflatpaks.sh"
    "installdockerservices.sh"
    "installepubtoaudiobook.sh"
    "installi3lockcolor.sh"
    "installbetterlockscreen.sh"
    "installi3logout.sh"
    "installautotiling.sh"
    "installsddmsimplicity.sh"
    "installxfcetheme.sh"
    "installrealvnc.sh"
    "setupcronjobs.sh"
    "updatei3ipc.sh"
    "setdpi.sh"
    "setcodecsbc.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        echo "Running $script..."
        bash "$SCRIPTS_DIR/$script" || echo "Warning: $script failed (continuing anyway)"
    else
        echo "Warning: $script not found — skipping"
    fi
done

# FINAL CLEAN RESTORE LIST – exactly what you want, nothing else
echo "Restoring user configurations from latest backup..."
config_mappings=(
    ".bin-personal:$USER_HOME/.bin-personal"
    ".config/brave-profiles:$USER_HOME/.config/brave-profiles"
    ".mozilla:$USER_HOME/.mozilla"
    ".ssh:$USER_HOME/.ssh"
    ".vscode:$USER_HOME/.vscode"
    "protonvpn-server-configs:$USER_HOME/protonvpn-server-configs"
    "Calibre-Library:$USER_HOME/Calibre-Library"
    "dotfiles:$USER_HOME/dotfiles"
    "OpenAudible:$USER_HOME/OpenAudible"
    "Trading:$USER_HOME/Trading"
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
echo "Reboot, choose i3 at login, and enjoy your perfect desktop."
echo "FINAL STEP AFTER REBOOT:"
echo " eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
