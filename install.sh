#!/bin/bash

# Script to coordinate installation of minti3 environment and copy user configurations

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$USER_HOME/github-repos/minti3/scripts"
CONFIG_SRC="$USER_HOME/github-repos/user-configs"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check for scripts and config directories
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "Error: Scripts directory $SCRIPTS_DIR not found. Exiting."
    exit 1
fi
if [ ! -d "$CONFIG_SRC" ]; then
    echo "Error: User configs directory $CONFIG_SRC not found. Exiting."
    exit 1
fi

# Copy user configuration files
echo "Copying user configuration files from $CONFIG_SRC..."
# Example mappings: adjust based on actual files in user-configs/
config_mappings=(
    ".bashrc:$USER_HOME/.bashrc"
    ".config/i3:$USER_HOME/.config/i3"
    ".config/polybar:$USER_HOME/.config/polybar"
    ".config/rofi:$USER_HOME/.config/rofi"
    ".config/dunst:$USER_HOME/.config/dunst"
    ".bin-personal:$USER_HOME/.bin-personal"
)
for mapping in "${config_mappings[@]}"; do
    src="${mapping%%:*}"
    dest="${mapping##*:}"
    src_path="$CONFIG_SRC/$src"
    if [ -e "$src_path" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$src_path" "$dest"
        if [ $? -eq 0 ]; then
            echo "Copied $src to $dest"
        else
            echo "Warning: Failed to copy $src to $dest"
        fi
    else
        echo "Warning: $src_path not found. Skipping."
    fi
done

# Run individual setup scripts
echo "Running minti3 setup scripts..."
scripts=(
    "install-i3-mint.sh"
    "install-i3lock-color.sh"
    "install-i3-logout.sh"
    "install-autotiling.sh"
    "install-sddm-simplicity.sh"
    "install-xfce-theme.sh"
    "install-realvnc.sh"
    "setup-cron-jobs.sh"
    "setup-grok-split-tunnel.sh"
    "setup-syncthing-selective.sh"
    "update-i3ipc.sh"
)

for script in "${scripts[@]}"; do
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        echo "Running $script..."
        bash "$SCRIPTS_DIR/$script"
        if [ $? -eq 0 ]; then
            echo "$script completed successfully."
        else
            echo "Warning: $script failed. Continuing."
        fi
    else
        echo "Warning: $script not found in $SCRIPTS_DIR. Skipping."
    fi
done

echo "minti3 installation complete."
