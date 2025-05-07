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
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
LOG_DIR="$USER_HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"
CONFIG_SRC="$USER_HOME/github-repos/backup.latest"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

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

# Check for config directory
if [ ! -d "$CONFIG_SRC" ]; then
    echo "Error: User configs directory $CONFIG_SRC not found. Exiting."
    exit 1
fi

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

# Copy user configuration files after scripts
echo "Copying user configuration files from $CONFIG_SRC..."
config_mappings=(
    ".config/polybar:$USER_HOME/.config/polybar"
    "sddm.conf:/etc/sddm.conf"
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

echo "minti3 installation complete."
