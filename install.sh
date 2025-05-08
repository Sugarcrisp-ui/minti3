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
CONFIG_SRC="$USER_HOME/github-repos/user-configs/backup.latest"

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
    ".config/alacritty:$USER_HOME/.config/alacritty"
    ".config/brave-profiles:$USER_HOME/.config/brave-profiles"
    ".config/dunst:$USER_HOME/.config/dunst"
    ".config/gtk-3.0:$USER_HOME/.config/gtk-3.0"
    ".config/i3:$USER_HOME/.config/i3"
    ".config/micro:$USER_HOME/.config/micro"
    ".config/polybar:$USER_HOME/.config/polybar"
    ".config/qBittorrent:$USER_HOME/.config/qBittorrent"
    ".config/rofi:$USER_HOME/.config/rofi"
    ".config/solaar:$USER_HOME/.config/solaar"
    ".config/sublime-text:$USER_HOME/.config/sublime-text"
    ".config/systemd:$USER_HOME/.config/systemd"
    ".config/Thunar:$USER_HOME/.config/Thunar"
    ".config/xfce4:$USER_HOME/.config/xfce4"
    ".config/zim:$USER_HOME/.config/zim"
    ".config/mimeapps.list:$USER_HOME/.config/mimeapps.list"
    ".fonts:$USER_HOME/.fonts"
    ".local/share/applications:$USER_HOME/.local/share/applications"
    ".mozilla:$USER_HOME/.mozilla"
    ".ssh:$USER_HOME/.ssh"
    ".vscode:$USER_HOME/.vscode"
    "bashrc-personal-sync:$USER_HOME/bashrc-personal-sync"
    "Notebooks:$USER_HOME/Notebooks"
    "protonvpn-server-configs:$USER_HOME/protonvpn-server-configs"
    "syncthing-shared:$USER_HOME/syncthing-shared"
    ".bashrc:$USER_HOME/.bashrc"
    ".dircolors:$USER_HOME/.dircolors"
    ".fehbg:$USER_HOME/.fehbg"
    ".gtkrc-2.0:$USER_HOME/.gtkrc-2.0"
    "xorg.conf.d/40-libinput.conf:/etc/X11/xorg.conf.d/40-libinput.conf"
)

for mapping in "${config_mappings[@]}"; do
    src="${mapping%%:*}"
    dest="${mapping##*:}"
    src_path="$CONFIG_SRC/$src"
    if [ -e "$src_path" ]; then
        mkdir -p "$(dirname "$dest")"
        if [[ "$dest" == /etc/* ]]; then
            sudo cp -r "$src_path" "$dest"
        else
            cp -r "$src_path" "$dest"
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

# Create .bashrc-personal symlink
if [ -e "$CONFIG_SRC/bashrc-personal-sync/.bashrc-personal" ]; then
    ln -sf "$USER_HOME/bashrc-personal-sync/.bashrc-personal" "$USER_HOME/.bashrc-personal"
    if [ $? -eq 0 ]; then
        echo "Created symlink $USER_HOME/.bashrc-personal -> $USER_HOME/bashrc-personal-sync/.bashrc-personal"
    else
        echo "Warning: Failed to create .bashrc-personal symlink"
    fi
else
    echo "Warning: $CONFIG_SRC/bashrc-personal-sync/.bashrc-personal not found. Skipping symlink creation."
fi

# Restore crontabs
if [ -e "$CONFIG_SRC/cron/user_crontab" ]; then
    crontab "$CONFIG_SRC/cron/user_crontab"
    if [ $? -eq 0 ]; then
        echo "Restored user crontab for $USER"
    else
        echo "Warning: Failed to restore user crontab"
    fi
else
    echo "Warning: $CONFIG_SRC/cron/user_crontab not found. Skipping."
fi
if [ -e "$CONFIG_SRC/cron/root_crontab" ]; then
    sudo crontab "$CONFIG_SRC/cron/root_crontab"
    if [ $? -eq 0 ]; then
        echo "Restored root crontab"
    else
        echo "Warning: Failed to restore root crontab"
    fi
else
    echo "Warning: $CONFIG_SRC/cron/root_crontab not found. Skipping."
fi

echo "minti3 installation complete."
