#!/bin/bash

# Script to coordinate installation of minti3 environment and copy user configurations

# Parse args (optional backup dir override)
BACKUP_OVERRIDE="${1:-}"

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"

# Dynamic CONFIG_SRC: Most recent daily backup
DAILY_BACKUP_DIR="/media/$USER/backup/daily"
if [ -n "$BACKUP_OVERRIDE" ]; then
    CONFIG_SRC="$BACKUP_OVERRIDE"
elif [ -d "$DAILY_BACKUP_DIR" ]; then
    LATEST_DAILY=$(ls -t "$DAILY_BACKUP_DIR"/daily.* 2>/dev/null | head -n1)
    if [ -n "$LATEST_DAILY" ] && [ -d "$LATEST_DAILY/backup.latest" ]; then
        CONFIG_SRC="$LATEST_DAILY/backup.latest"
    else
        echo "Error: No valid daily backups found in $DAILY_BACKUP_DIR (need daily.X/backup.latest). Exiting."
        exit 1
    fi
else
    echo "Error: Daily backups dir $DAILY_BACKUP_DIR not found. Exiting."
    exit 1
fi

# Redirect output to timestamped log file and terminal
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"
echo "Using backup dir: $CONFIG_SRC"

# Cache sudo credentials
echo "Please enter your sudo password to cache credentials for script execution:"
sudo -v
if [ $? -ne 0 ]; then
    echo "Error: Failed to cache sudo credentials. Exiting."
    exit 1
fi

# Check and create github-repos directory
if [ ! -d "$GITHUB_REPOS_DIR" ]; then
    echo "Creating $GITHUB_REPOS_DIR..."
    mkdir -p "$GITHUB_REPOS_DIR"
fi

# Clone minti3 if not already present
if [ ! -d "$GITHUB_REPOS_DIR/minti3" ]; then
    echo "Cloning minti3 to $GITHUB_REPOS_DIR/minti3..."
    cd "$GITHUB_REPOS_DIR"
    git clone https://github.com/Sugarcrisp-ui/minti3.git
    if [ $? -eq 0 ]; then
        echo "Cloned minti3 successfully."
    else
        echo "Error: Failed to clone minti3. Exiting."
        exit 1
    fi
fi

# Change to minti3 directory
cd "$GITHUB_REPOS_DIR/minti3"
if [ $? -ne 0 ]; then
    echo "Error: Failed to change to $GITHUB_REPOS_DIR/minti3. Exiting."
    exit 1
fi

# Check for scripts directory
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory $SCRIPTS_DIR not found. Exiting."
    exit 1
fi

# Mount external LUKS drive
echo "Mounting external LUKS drive..."
if ! bash "$SCRIPTS_DIR/automount-external-luks.sh"; then
    echo "Error: LUKS mount failed. Exiting."
    exit 1
fi

# Check for config directory
if [ ! -d "$CONFIG_SRC" ]; then
    echo "Error: User configs directory $CONFIG_SRC not found. Exiting."
    exit 1
fi

# Run individual setup scripts
echo "Running minti3 setup scripts..."
scripts=(
    "automount-external-luks.sh"
    "install-i3-mint.sh"
    "install-i3-apps.sh"
    "install-i3lock-color.sh"
    "install-i3-logout.sh"
    "install-autotiling.sh"
    "install-sddm-simplicity.sh"
    "install-xfce-theme.sh"
    "install-realvnc.sh"
    "setup-cron-jobs.sh"
    "update-i3ipc.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        echo "Running $script..."
        if ! bash "$SCRIPTS_DIR/$script"; then
            echo "Warning: $script failed with exit code ${PIPESTATUS[0]}. Check $OUTPUT_FILE for details."
        fi
    else
        echo "Warning: $script not found in $SCRIPTS_DIR. Skipping."
    fi
done

# Copy user configuration files from backup
echo "Copying user configuration files from $CONFIG_SRC..."

# Configuration mappings (source:destination)
config_mappings=(
    ".config/brave-profiles:$USER_HOME/.config/brave-profiles"
    ".mozilla:$USER_HOME/.mozilla"
    ".ssh:$USER_HOME/.ssh"
    ".vscode:$USER_HOME/.vscode"
    "Notebooks:$USER_HOME/Notebooks"
    "protonvpn-server-configs:$USER_HOME/protonvpn-server-configs"
    "sddm.conf:/etc/sddm.conf"
    "sudoers:/etc/sudoers"
#    "xorg.conf.d/40-libinput.conf:/etc/X11/xorg.conf.d/40-libinput.conf"
)

for mapping in "${config_mappings[@]}"; do
    src="${mapping%%:*}"
    dest="${mapping##*:}"
    src_path="$CONFIG_SRC/$src"
    if [ -e "$src_path" ] || [ -L "$src_path" ]; then
        mkdir -p "$(dirname "$dest")"
        # Use cp -P for .bashrc-personal to preserve symlink
        if [[ "$src" == ".bashrc-personal" ]]; then
            cp -Pf "$src_path" "$dest"
        # Use cp -rf for directories to copy contents and overwrite
        elif [ -d "$src_path" ] && [ ! -L "$src_path" ]; then
            cp -rf "$src_path/." "$dest"
        # Use cp -f for files to overwrite
        else
            cp -f "$src_path" "$dest"
        fi
        if [ $? -eq 0 ]; then
            echo "Copied $src to $dest"
        else
            echo "Warning: Failed to copy $src to $dest"
        fi
    else
        echo "Warning: $src_path not found. Skipping."
    fi
done

# Restore crontabs
if [ -f "$CONFIG_SRC/cron/user_crontab" ]; then
    sudo crontab -u "$USER" "$CONFIG_SRC/cron/user_crontab"
    if [ $? -eq 0 ]; then
        echo "Restored user crontab for $USER"
    else
        echo "Warning: Failed to restore user crontab"
    fi
else
    echo "Warning: $CONFIG_SRC/cron/user_crontab not found. Skipping."
fi

if [ -f "$CONFIG_SRC/cron/root_crontab" ]; then
    sudo crontab -u root "$CONFIG_SRC/cron/root_crontab"
    if [ $? -eq 0 ]; then
        echo "Restored root crontab"
    else
        echo "Warning: Failed to restore root crontab"
    fi
else
    echo "Warning: $CONFIG_SRC/cron/root_crontab not found. Skipping."
fi

echo "minti3 installation and configuration restore complete."
