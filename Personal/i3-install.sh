#!/bin/bash

# Master script to install and set up i3 on Linux Mint

# Ensure script is run with sudo for installation
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Warn about InSync
echo "Warning: If InSync is running, it may cause issues with this script. Please ensure InSync is stopped before proceeding."
read -p "Press Enter to continue, or Ctrl+C to abort and stop InSync..."

# Variables
USER="brett"
USER_HOME="/home/$USER"
SCRIPTS_DIR="$USER_HOME/minti3/Personal"

# Function to run a script and check for errors
run_script() {
    local script="$1"
    echo "Running $script..."
    bash "$SCRIPTS_DIR/$script"
    if [ $? -ne 0 ]; then
        echo "Error: $script failed. Exiting."
        exit 1
    fi
}

# Section 1: Install Core i3 Components and Dependencies
run_script "install-i3-mint.sh"

# Section 2: Install i3lock-color
run_script "install-i3lock-color.sh"

# Section 3: Set Up Virtual Environment and Install i3ipc
run_script "install-i3ipc.sh"

# Section 4: Install autotiling
run_script "install-autotiling.sh"

# Section 5: Install i3-logout and betterlockscreen
run_script "install-i3-logout.sh"

# Section 6: Install SDDM and Simplicity Theme
run_script "install-sddm-simplicity.sh"

# Section 7: Install Additional i3 Apps
run_script "install-i3-apps.sh"

# Section 8: Install GitHub Desktop
run_script "install-github-desktop.sh"

# Section 9: Install RealVNC Server and Viewer
run_script "install-realvnc.sh"

# Section 10: Install XFCE Theme
run_script "install-xfce-theme.sh"

# Section 11: Set Up Dotfiles Symlinks
run_script "install-dotfiles-symlinks.sh"

# Section 12: Set Up Cron Jobs
echo "Setting up cron jobs..."
run_script "setup-cron-jobs.sh"

# Ensure dunst is running for betterlockscreen verification
sudo -u "$USER" -E dunst &

# Section 13: Verify Installations
echo "Verifying installations..."
i3 --version
polybar --version
rofi --version
dunst --version
i3lock-color --version
DISPLAY=:0 sudo -u "$USER" -E i3-logout --version
DISPLAY=:0 sudo -u "$USER" -E betterlockscreen --version
DISPLAY=:0 sudo -u "$USER" -E protonvpn-app --version
DISPLAY=:0 sudo -u "$USER" -E github-desktop --version
vncserver-x11 --version
xfconf-query -c xsettings -p /Net/ThemeName
"$USER_HOME/i3ipc-venv/bin/pip" show i3ipc
cat /etc/sddm.conf.d/kde_settings.conf

echo "Mint i3 installation complete."
