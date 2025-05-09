#!/bin/bash

# Script to coordinate installation of minti3 environment and copy user configurations

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
HOME="/home/brett"
GITHUB_REPOS_DIR="$HOME/github-repos"
LOG_DIR="$HOME/log-files/install"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-$TIMESTAMP.txt"
SCRIPTS_DIR="$GITHUB_REPOS_DIR/minti3/scripts"
CONFIG_SRC="/media/brett/backup/user-configs/backup.latest"

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
    "install-i3-apps.sh"
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
        if [ ! -x "$SCRIPTS_DIR/$script" ]; then
            echo "Making $script executable..."
            chmod +x "$SCRIPTS_DIR/$script"
        fi
        echo "Running $script..."
        # Run script with sudo -S, capture output and errors
        sudo -S bash "$SCRIPTS_DIR/$script" >> "$OUTPUT_FILE" 2>&1
        if [ $? -eq 0 ]; then
            echo "$script completed successfully."
        else
            echo "Warning: $script failed with exit code $?. Check $OUTPUT_FILE for details."
        fi
    else
        echo "Warning: $script not found in $SCRIPTS_DIR. Skipping."
    fi
done

# Copy user configuration files from backup.latest
echo "Copying user configuration files from $CONFIG_SRC..."

# Configuration mappings (source:destination)
config_mappings=(
    ".config/alacritty:$HOME/.config/alacritty"
    ".config/brave-profiles:$HOME/.config/brave-profiles"
    ".config/dunst:$HOME/.config/dunst"
    ".config/gtk-3.0:$HOME/.config/gtk-3.0"
    ".config/i3:$HOME/.config/i3"
    ".config/micro:$HOME/.config/micro"
    ".config/polybar:$HOME/.config/polybar"
    ".config/qBittorrent:$HOME/.config/qBittorrent"
    ".config/rofi:$HOME/.config/rofi"
    ".config/solaar:$HOME/.config/solaar"
    ".config/sublime-text:$HOME/.config/sublime-text"
    ".config/systemd:$HOME/.config/systemd"
    ".config/Thunar:$HOME/.config/Thunar"
    ".config/xfce4:$HOME/.config/xfce4"
    ".config/zim:$HOME/.config/zim"
    ".config/mimeapps.list:$HOME/.config/mimeapps.list"
    ".fonts:$HOME/.fonts"
    "applications:$HOME/.local/share/applications"
    ".mozilla:$HOME/.mozilla"
    ".ssh:$HOME/.ssh"
    ".vscode:$HOME/.vscode"
    "bashrc-personal-sync:$HOME/bashrc-personal-sync"
    "Notebooks:$HOME/Notebooks"
    "protonvpn-server-configs:$HOME/protonvpn-server-configs"
    "syncthing-shared:$HOME/syncthing-shared"
    ".bashrc:$HOME/.bashrc"
    ".bashrc-personal:$HOME/.bashrc-personal"
    ".dircolors:$HOME/.dircolors"
    ".fehbg:$HOME/.fehbg"
    ".gtkrc-2.0:$HOME/.gtkrc-2.0"
    "xorg.conf.d/40-libinput.conf:/etc/X11/xorg.conf.d/40-libinput.conf"
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
    sudo crontab -u brett "$CONFIG_SRC/cron/user_crontab"
    if [ $? -eq 0 ]; then
        echo "Restored user crontab for brett"
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
