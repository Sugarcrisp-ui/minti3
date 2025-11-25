#!/bin/bash
# install.sh – minti3 full system setup + restore (2025 final version)

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
if [ ! -d "/media/$USER/backup/daily.latest/backup.latest" ]; then
    echo "ERROR: External LUKS backup drive not found!"
    echo "       Plug in your drive and re-run this script."
    echo "       Without it you will NOT have:"
    echo "         • dotfiles (.config, .bin-personal, etc.)"
    echo "         • SSH keys"
    echo "         • personal data (Notebooks, warp-terminal, etc.)"
    exit 1
fi

CONFIG_SRC="/media/$USER/backup/daily.latest/backup.latest"
echo "External backup found → starting FULL perfect restore..."

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
    "install-i3lock-color.sh"
    "install-i3-logout.sh"
    "install-autotiling.sh"
    "install-sddm-simplicity.sh"
    "install-xfce-theme.sh"
    "install-realvnc.sh"
    "setup-cron-jobs.sh"
    "update-i3ipc.sh"
    "install-epub-to-audiobook.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        echo "Running $script..."
        bash "$SCRIPTS_DIR/$script" || echo "Warning: $script failed"
    else
        echo "Warning: $script not found — skipping"
    fi
done

# Restore user configs from external drive
echo "Restoring user configurations from backup..."
config_mappings=(
    ".config/brave-profiles:$USER_HOME/.config/brave-profiles"
    ".mozilla:$USER_HOME/.mozilla"
    ".ssh:$USER_HOME/.ssh"
    ".vscode:$USER_HOME/.vscode"
    "protonvpn-server-configs:$USER_HOME/protonvpn-server-configs"
    "sddm.conf:/etc/sddm.conf"
    "sudoers:/etc/sudoers"
)

for mapping in "${config_mappings[@]}"; do
    src="${mapping%%:*}"
    dest="${mapping##*:}"
    src_path="$CONFIG_SRC/$src"
    if [ -e "$src_path" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -rf "$src_path" "$dest"
        echo "Restored $src → $dest"
    fi
done

# Restore crontabs
[ -f "$CONFIG_SRC/cron/user_crontab" ] && sudo crontab -u "$USER" "$CONFIG_SRC/cron/user_crontab" && echo "User crontab restored"
[ -f "$CONFIG_SRC/cron/root_crontab" ] && sudo crontab -u root "$CONFIG_SRC/cron/root_crontab" && echo "Root crontab restored"

echo "=== minti3 installation + full restore complete! ==="
echo "Reboot and enjoy your perfect i3 desktop."

echo "------------------------------------------------------------"
echo "FINAL STEP AFTER REBOOT:"
echo "   Run once (or add to i3 config):"
echo "       eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
echo "   This loads your SSH key for GitHub (already restored from backup)"
echo "------------------------------------------------------------"
