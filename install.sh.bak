#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Set environment for D-Bus and XFCE compatibility
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/$(id -u $USER)
export XDG_CONFIG_HOME=/home/$USER/.config
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $USER)/bus

# Master script to install and set up i3 on a fresh Linux Mint XFCE system

# Variables
USER=$(whoami)
USER_HOME="/home/$USER"
SCRIPTS_DIR="$USER_HOME/minti3/scripts"

# Function to run a script and check for errors
run_script() {
    local script="$1"
    local sudo_needed="${2:-false}"
    echo "Running $script..."
    echo "Current user: $(whoami), USER=$USER, HOME=$HOME" >&2
    if [ "$sudo_needed" = "true" ]; then
        sudo -E bash "$SCRIPTS_DIR/$script"
    else
        bash "$SCRIPTS_DIR/$script"
    fi
    if [ $? -ne 0 ]; then
        echo "Error: $script failed. Exiting."
        exit 1
    fi
}

# Warn about InSync
echo "Warning: If InSync is running, it may cause issues with this script. Please ensure InSync is stopped before proceeding."
read -p "Press Enter to continue, or Ctrl+C to abort and stop InSync..."

# Clone or update dotfiles-minti3 repository
if [ ! -d "$USER_HOME/dotfiles-minti3" ]; then
    echo "Cloning dotfiles-minti3 repository..."
    git clone https://github.com/Sugarcrisp-ui/dotfiles-minti3.git "$USER_HOME/dotfiles-minti3"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone dotfiles-minti3 repository. Exiting."
        exit 1
    fi
else
    echo "dotfiles-minti3 repository already exists at $USER_HOME/dotfiles-minti3, updating..."
    cd "$USER_HOME/dotfiles-minti3"
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update dotfiles-minti3 repository. Exiting."
        exit 1
    fi
fi

# Section 1: Install Core i3 Components and Dependencies
run_script "install-i3-mint.sh" false

# Section 2: Install i3lock-color
run_script "install-i3lock-color.sh" false

# Section 3: Set Up Virtual Environment and Install i3ipc
run_script "install-i3ipc.sh" false

# Section 4: Install autotiling
run_script "install-autotiling.sh" false

# Section 5: Install i3-logout and betterlockscreen
run_script "install-i3-logout.sh" false

# Section 6: Install SDDM and Simplicity Theme
run_script "install-sddm-simplicity.sh" true

# Section 7: Install Additional i3 Apps
run_script "install-i3-apps.sh" true

# Section 8: Install GitHub Desktop
echo "Installing GitHub Desktop via Flatpak..."
sudo flatpak install flathub io.github.shiftey.Desktop -y
if [ $? -ne 0 ]; then
    echo "Error: GitHub Desktop installation failed. Exiting."
    exit 1
fi

# Section 9: Install RealVNC Server and Viewer
run_script "install-realvnc.sh" true

# Section 10: Install XFCE Theme
run_script "install-xfce-theme.sh" true

# Section 11: Set Up Cron Jobs
echo "Setting up cron jobs..."
run_script "setup-cron-jobs.sh" true

# Section 12: Apply Dotfiles by Direct Copying (Final Step)
echo "Applying dotfiles by copying directly..."
mkdir -p ~/.config ~/.local/share/applications ~/.fonts
sudo mkdir -p /etc/X11/xorg.conf.d

# Replace specific files
cp -v ~/dotfiles-minti3/.bashrc ~/.bashrc
cp -v ~/dotfiles-minti3/.bashrc-personal ~/.bashrc-personal
cp -v ~/dotfiles-minti3/.fehbg ~/.fehbg
cp -v ~/dotfiles-minti3/.gtkrc-2.0.mine ~/.gtkrc-2.0.mine

# Replace or create .fonts directory
rm -rf ~/.fonts
cp -rv ~/dotfiles-minti3/.fonts ~/.fonts

# Add contents to .local, overwrite existing, don't remove non-matching
cp -rv ~/dotfiles-minti3/.local/share/applications/* ~/.local/share/applications/

# Replace matching .config subdirectories, don't remove non-matching
for dir in ~/dotfiles-minti3/.config/*; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        mkdir -p ~/.config/$dir_name
        cp -rv $dir/* ~/.config/$dir_name/
    fi
done

# Replace system configuration files
sudo cp -v ~/dotfiles-minti3/sddm.conf /etc/sddm.conf
sudo cp -rv ~/dotfiles-minti3/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

# Select Polybar configuration based on system type
echo "Selecting Polybar configuration based on system type..."
HOSTNAME=$(hostname)
POLYBAR_CONFIG_DIR="$USER_HOME/.config/polybar"
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

# Section 13: Verify Installations
echo "Verifying installations..."
i3 --version
polybar --version
rofi --version > /dev/null 2>&1
dunst --version
i3lock --version
sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus XDG_SESSION_TYPE=x11 NO_AT_BRIDGE=1 i3-logout -h
# protonvpn-app --version  # Commented out due to installation issues
flatpak run io.github.shiftey.Desktop --version
vncserver-x11 --version
xfconf-query -c xsettings -p /Net/ThemeName
"$USER_HOME/i3ipc-venv/bin/pip" show i3ipc
cat /etc/sddm.conf

echo "Mint i3 installation complete."
