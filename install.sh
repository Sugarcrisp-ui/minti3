#!/bin/bash

# Prompt for sudo password early to cache credentials
sudo -v
if [ $? -ne 0 ]; then
    echo "Error: Sudo authentication failed. Exiting."
    exit 1
fi

# Variables for logging
OUTPUT_FILE="$HOME/log-files/install/install-output.txt"
mkdir -p "$HOME/log-files/install"

# Redirect output to file
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

export DEBIAN_FRONTEND=noninteractive

# Set environment for D-Bus and XFCE compatibility
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/$(id -u $USER)
export XDG_CONFIG_HOME="$HOME/.config"
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $USER)/bus

# Master script to install and set up i3 on a fresh Linux Mint XFCE system

# Variables
USER=$(whoami)
USER_HOME="$HOME"
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
MINTI3_DIR="$GITHUB_REPOS_DIR/minti3"
USER_CONFIGS_DIR="$GITHUB_REPOS_DIR/user-configs"
SCRIPTS_DIR="$MINTI3_DIR/scripts"
EXTERNAL_BACKUP_DIR="/media/brett/backup"

# Ensure minti3 is in ~/github-repos/
if [ ! -d "$MINTI3_DIR" ]; then
    echo "minti3 not found in $GITHUB_REPOS_DIR. Checking for $USER_HOME/minti3..."
    if [ -d "$USER_HOME/minti3" ]; then
        echo "Found $USER_HOME/minti3. Moving to $GITHUB_REPOS_DIR..."
        mkdir -p "$GITHUB_REPOS_DIR"
        mv "$USER_HOME/minti3" "$GITHUB_REPOS_DIR/"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to move $USER_HOME/minti3 to $GITHUB_REPOS_DIR. Exiting."
            exit 1
        fi
    else
        echo "Error: $USER_HOME/minti3 not found, and $MINTI3_DIR does not exist. Please clone the repository first. Exiting."
        exit 1
    fi
fi

# Function to run a script and check for errors
run_script() {
    local script="$1"
    echo "Running $script..."
    echo "Current user: $(whoami), USER=$USER, HOME=$HOME" >&2
    bash "$SCRIPTS_DIR/$script"
    if [ $? -ne 0 ]; then
        echo "Error: $script failed. Exiting."
        exit 1
    fi
}

# Warn about InSync
echo "Warning: If InSync is running, it may cause issues with this script. Please ensure InSync is stopped before proceeding."
read -p "Press Enter to continue, or Ctrl+C to abort and stop InSync..."

# Clone dependency repositories
echo "Cloning dependency repositories..."
mkdir -p "$GITHUB_REPOS_DIR"
declare -A repos=(
    ["user-configs"]="https://github.com/Sugarcrisp-ui/user-configs.git"
    ["i3-logout"]="https://github.com/Sugarcrisp-ui/i3-logout.git"
    ["autotiling"]="https://github.com/Sugarcrisp-ui/autotiling.git"
    ["sddm-themes"]="https://github.com/Sugarcrisp-ui/sddm-themes.git"
    ["i3lock-color"]="https://github.com/Raymo111/i3lock-color.git"
    ["betterlockscreen"]="https://github.com/betterlockscreen/betterlockscreen.git"
)
for repo in "${!repos[@]}"; do
    repo_dir="$GITHUB_REPOS_DIR/$repo"
    if [ ! -d "$repo_dir" ]; then
        echo "Cloning $repo..."
        git clone "${repos[$repo]}" "$repo_dir"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to clone $repo repository. Exiting."
            exit 1
        fi
    else
        echo "$repo repository already exists at $repo_dir, updating..."
        cd "$repo_dir"
        git pull
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update $repo repository. Exiting."
            exit 1
        fi
    fi
done

# Section 1: Install Core i3 Components and Dependencies
run_script "install-i3-mint.sh"

# Section 2: Install i3lock-color
run_script "install-i3lock-color.sh"

# Section 3: Install autotiling
run_script "install-autotiling.sh"

# Section 4: Install i3-logout and betterlockscreen
run_script "install-i3-logout.sh"
run_script "install-betterlockscreen.sh"

# Section 5: Install SDDM and Simplicity Theme
run_script "install-sddm-simplicity.sh"

# Setup Brave Browser repository
echo "Setting up Brave Browser repository..."
sudo apt install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt update

# Section 6: Install Additional i3 Apps
run_script "install-i3-apps.sh"

# Section 7: Install GitHub Desktop
echo "Installing GitHub Desktop via Flatpak..."
sudo flatpak install flathub io.github.shiftey.Desktop -y
if [ $? -ne 0 ]; then
    echo "Error: GitHub Desktop installation failed. Exiting."
    exit 1
fi

# Section 8: Install RealVNC Server and Viewer
run_script "install-realvnc.sh"

# Section 9: Install XFCE Theme
run_script "install-xfce-theme.sh"

# Section 10: Set Up Cron Jobs
run_script "setup-cron-jobs.sh"

# Section 11: Set Up Grok Split Tunnel
run_script "setup-grok-split-tunnel.sh"

# Section 12: Apply User Configurations by Direct Copying
echo "Applying user configurations by copying from latest backup..."
EXTERNAL_BACKUP_DIR="/media/brett/backup"
LATEST_BACKUP=""
LATEST_EXTERNAL_BACKUP=""

# Find latest backup in user-configs
echo "Checking backup.latest link: $USER_CONFIGS_DIR/backup.latest"
if [ -L "$USER_CONFIGS_DIR/backup.latest" ]; then
    echo "backup.latest is a symbolic link"
    TARGET_DIR=$(readlink -f "$USER_CONFIGS_DIR/backup.latest")
    echo "Target directory: $TARGET_DIR"
    if [ -d "$TARGET_DIR" ]; then
        echo "Target directory exists"
        LATEST_BACKUP="$TARGET_DIR"
        echo "Resolved LATEST_BACKUP: $LATEST_BACKUP"
    else
        echo "Error: Target directory $TARGET_DIR does not exist"
        exit 1
    fi
else
    echo "Error: backup.latest is not a valid symbolic link in $USER_CONFIGS_DIR"
    exit 1
fi

# Find latest backup in external drive
if [ -L "$EXTERNAL_BACKUP_DIR/backup.latest" ] && [ -d "$(readlink "$EXTERNAL_BACKUP_DIR/backup.latest")" ]; then
    LATEST_EXTERNAL_BACKUP=$(readlink -f "$EXTERNAL_BACKUP_DIR/backup.latest")
else
    echo "Warning: No valid backup.latest link found in $EXTERNAL_BACKUP_DIR. Skipping external backup files."
fi

# Create necessary directories
mkdir -p "$HOME/.config" "$HOME/.local/share/applications" "$HOME/.ssh"
sudo mkdir -p /etc/X11/xorg.conf.d

# Copy specific files from latest backup, skip if missing
for file in .bashrc bashrc-personal-sync/.bashrc-personal .fehbg .gtkrc-2.0.mine .dircolors; do
    if [ -f "$LATEST_BACKUP/$file" ]; then
        cp -v "$LATEST_BACKUP/$file" "$HOME/$(basename "$file")"
    else
        echo "Warning: $file not found in $LATEST_BACKUP. Skipping."
    fi
done

# Copy .local/share/applications
if [ -d "$LATEST_BACKUP/applications/applications" ]; then
    cp -rv "$LATEST_BACKUP/applications/applications/"* "$HOME/.local/share/applications/"
elif [ -d "$LATEST_BACKUP/applications" ]; then
    cp -rv "$LATEST_BACKUP/applications/"* "$HOME/.local/share/applications/"
else
    echo "Warning: applications directory not found in $LATEST_BACKUP. Skipping."
fi

# Copy .config subdirectories, excluding .git
if [ -d "$LATEST_BACKUP/.config" ]; then
    find "$LATEST_BACKUP/.config/" -maxdepth 1 -type d ! -path "$LATEST_BACKUP/.config" -exec basename {} \; | while read -r dir_name; do
        if [ -d "$LATEST_BACKUP/.config/$dir_name" ]; then
            mkdir -p "$HOME/.config/$dir_name"
            cp -rv --no-preserve=mode,ownership "$LATEST_BACKUP/.config/$dir_name/"* "$HOME/.config/$dir_name/" 2>/dev/null || echo "Warning: Some files in $dir_name failed to copy due to permissions."
        fi
    done
else
    echo "Warning: .config directory not found in $LATEST_BACKUP. Skipping."
fi

# Copy system configuration files
if [ -f "$LATEST_BACKUP/etc/sddm.conf" ]; then
    sudo cp -v "$LATEST_BACKUP/etc/sddm.conf" /etc/sddm.conf
else
    echo "Warning: sddm.conf not found in $LATEST_BACKUP. Skipping."
fi
if [ -d "$LATEST_BACKUP/xorg.conf.d" ]; then
    sudo cp -rv "$LATEST_BACKUP/xorg.conf.d/"* /etc/X11/xorg.conf.d/
else
    echo "Warning: xorg.conf.d directory not found in $LATEST_BACKUP. Skipping."
fi

# Copy secure configurations from external backup
if [ -n "$LATEST_EXTERNAL_BACKUP" ] && [ -d "$LATEST_EXTERNAL_BACKUP/.ssh" ]; then
    cp -rv "$LATEST_EXTERNAL_BACKUP/.ssh/"* "$HOME/.ssh/"
    chmod 600 "$HOME/.ssh/"*
    echo "Copied .ssh configurations from external backup."
else
    echo "Warning: .ssh directory not found in $LATEST_EXTERNAL_BACKUP. Skipping."
fi

# Select Polybar configuration based on system type
echo "Selecting Polybar configuration based on system type..."
HOSTNAME=$(hostname)
POLYBAR_CONFIG_DIR="$HOME/.config/polybar"
if [ "$HOSTNAME" = "brett-ms-7d82" ]; then
    # Desktop: Use desktop-config.ini
    cp "$POLYBAR_CONFIG_DIR/desktop-config.ini" "$POLYBAR_CONFIG_DIR/config.ini"
    echo "Applied desktop Polybar configuration."
elif [ "$HOSTNAME" = "brett-K501UX" ]; then
    # Laptop: Use laptop-config.ini
    cp "$POLYBAR_CONFIG_DIR/laptop-config.ini" "$POLYBAR_CONFIG_DIR/config.ini"
    echo "Applied laptop Polybar configuration."
else
    # Default: Use laptop config (can adjust for VM later)
    cp "$POLYBAR_CONFIG_DIR/laptop-config.ini" "$POLYBAR_CONFIG_DIR/config.ini"
    echo "Applied default (laptop) Polybar configuration."
fi

# Ensure dunst is running for XFCE session
if ! pgrep -u "$USER" dunst >/dev/null; then
    dunst &
fi

# Configure passwordless sudo for apt-updates.sh
echo "Configuring passwordless sudo for apt update..."
SUDOERS_FILE="/etc/sudoers.d/brett-apt"
echo "brett ALL=(ALL) NOPASSWD: /usr/bin/apt update" | sudo tee "$SUDOERS_FILE" >/dev/null
sudo chmod 440 "$SUDOERS_FILE"

# Install crontab settings
echo "Installing crontab settings..."
mkdir -p "$USER_CONFIGS_DIR/crontabs"
if [ -f "$LATEST_BACKUP/crontabs/crontab-user" ]; then
    cp "$LATEST_BACKUP/crontabs/crontab-user" "$USER_CONFIGS_DIR/crontabs/crontab-user"
    cp "$LATEST_BACKUP/crontabs/crontab-user" "$USER_CONFIGS_DIR/crontabs/crontab-user.bak"
    crontab "$USER_CONFIGS_DIR/crontabs/crontab-user"
    echo "Installed user crontab from $LATEST_BACKUP/crontabs/crontab-user."
else
    echo "Warning: crontab-user not found in $LATEST_BACKUP/crontabs. Skipping user crontab."
fi
if [ -f "$LATEST_BACKUP/crontabs/crontab-sudo" ]; then
    cp "$LATEST_BACKUP/crontabs/crontab-sudo" "$USER_CONFIGS_DIR/crontabs/crontab-sudo"
    cp "$LATEST_BACKUP/crontabs/crontab-sudo" "$USER_CONFIGS_DIR/crontabs/crontab-sudo.bak"
    sudo crontab "$USER_CONFIGS_DIR/crontabs/crontab-sudo"
    echo "Installed sudo crontab from $LATEST_BACKUP/crontabs/crontab-sudo."
else
    echo "Warning: crontab-sudo not found in $LATEST_BACKUP/crontabs. Skipping sudo crontab."
fi

# Install PulseAudio and remove PipeWire
echo "Installing PulseAudio and removing PipeWire..."
sudo apt remove -y pipewire pipewire-audio pipewire-alsa pipewire-pulse
sudo apt install -y pulseaudio pulseaudio-utils
pulseaudio --start

# Configure HDMI sink for PulseAudio
echo "Configuring HDMI sink for PulseAudio..."
pactl load-module module-alsa-sink device=hw:0,3 sink_name=hdmi-sink
pactl set-default-sink hdmi-sink

# Configure LUKS auto-unlock and automount for desktop (brett-ms-7d82)
if [ "$(hostname)" = "brett-ms-7d82" ]; then
    echo "Configuring LUKS auto-unlock for desktop..."
    sudo mkdir -p /etc/luks-keys
    sudo dd if=/dev/urandom of=/etc/luks-keys/backup-key bs=512 count=8
    sudo chmod 400 /etc/luks-keys/backup-key
    sudo cryptsetup luksAddKey /dev/disk/by-uuid/8e7807ea-b45b-4cfe-a767-727994c3d5cd /etc/luks-keys/backup-key
    echo "backup_crypt /dev/disk/by-uuid/8e7807ea-b45b-4cfe-a767-727994c3d5cd /etc/luks-keys/backup-key luks" | sudo tee /etc/crypttab
    sudo mkdir -p /media/brett/backup
    echo "/dev/mapper/backup_crypt /media/brett/backup ext4 defaults 0 2" | sudo tee -a /etc/fstab
    sudo update-initramfs -u
fi

# Section 12.5: Install Fonts from External Drive
echo "Installing fonts from external drive..."
if [ -n "$LATEST_EXTERNAL_BACKUP" ] && [ -d "$LATEST_EXTERNAL_BACKUP/.fonts" ]; then
    mkdir -p "$HOME/.fonts"
    cp -rv "$LATEST_EXTERNAL_BACKUP/.fonts/"* "$HOME/.fonts/"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy fonts from $LATEST_EXTERNAL_BACKUP/.fonts/. Exiting."
        exit 1
    fi
    fc-cache -fv
else
    echo "Warning: Font directory $LATEST_EXTERNAL_BACKUP/.fonts not found. Skipping font installation."
fi

# Section 12.6: Install Mozilla Configuration from External Drive
echo "Installing Mozilla configuration from external drive..."
if [ -n "$LATEST_EXTERNAL_BACKUP" ] && [ -d "$LATEST_EXTERNAL_BACKUP/.mozilla" ]; then
    mkdir -p "$HOME/.mozilla"
    cp -rv "$LATEST_EXTERNAL_BACKUP/.mozilla/"* "$HOME/.mozilla/"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy Mozilla configuration from $LATEST_EXTERNAL_BACKUP/.mozilla/. Exiting."
        exit 1
    fi
else
    echo "Warning: Mozilla configuration directory $LATEST_EXTERNAL_BACKUP/.mozilla not found. Skipping Mozilla configuration installation."
fi

# Section 13: Verify Installations
echo "Verifying installations..."
#i3 --version
polybar --version
rofi --version > /dev/null 2>&1
dunst --version
i3lock --version
#sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus XDG_SESSION_TYPE=x11 NO_AT_BRIDGE=1 i3-logout -h
flatpak run io.github.shiftey.Desktop --version
vncserver-x11 --version
#xfconf-query -c xsettings -p /Net/ThemeName
cat /etc/sddm.conf

echo "Mint i3 installation complete."
