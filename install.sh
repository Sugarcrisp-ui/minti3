#!/bin/bash

# Set environment for D-Bus and XFCE compatibility
export DISPLAY=:0
export XDG_SESSION_TYPE=x11
export XDG_RUNTIME_DIR=/run/user/$(id -u brett)
export XDG_CONFIG_HOME=/home/brett/.config
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus

# Master script to install and set up i3 on a fresh Linux Mint XFCE system

# Variables
USER="brett"
USER_HOME="/home/$USER"
SCRIPTS_DIR="$USER_HOME/minti3/install-scripts"

# Function to run a script and check for errors
run_script() {
    local script="$1"
    local sudo_needed="${2:-false}"
    echo "Running $script..."
    if [ "$sudo_needed" = "true" ]; then
        sudo -E DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus bash "$SCRIPTS_DIR/$script"
    else
        DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus bash "$SCRIPTS_DIR/$script"
    fi
    if [ $? -ne 0 ]; then
        echo "Error: $script failed. Exiting."
        exit 1
    fi
}

# Warn about InSync
echo "Warning: If InSync is running, it may cause issues with this script. Please ensure InSync is stopped before proceeding."
read -p "Press Enter to continue, or Ctrl+C to abort and stop InSync..."

# Clone dotfiles-minti3 repository if it doesn't exist
if [ ! -d "$USER_HOME/dotfiles-minti3" ]; then
    echo "Cloning dotfiles-minti3 repository..."
    git clone https://github.com/Sugarcrisp-ui/dotfiles-minti3.git "$USER_HOME/dotfiles-minti3"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone dotfiles-minti3 repository. Exiting."
        exit 1
    fi
else
    echo "dotfiles-minti3 repository already exists at $USER_HOME/dotfiles-minti3, skipping clone."
fi

# Section 1: Install Core i3 Components and Dependencies
run_script "install-i3-mint.sh" true

# Section 2: Install i3lock-color
run_script "install-i3lock-color.sh" true

# Section 3: Set Up Virtual Environment and Install i3ipc
run_script "install-i3ipc.sh"

# Section 4: Install autotiling
run_script "install-autotiling.sh"

# Section 5: Install i3-logout and betterlockscreen
run_script "install-i3-logout.sh"

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
run_script "install-xfce-theme.sh"

# Section 11: Apply Dotfiles by Direct Copying
echo "Applying dotfiles by copying directly..."
mkdir -p ~/.config/i3 ~/.config/dunst ~/.config/rofi ~/.config/betterlockscreen ~/.config/bluetooth-connect ~/.config/i3-logout
mkdir -p ~/.config/geany ~/.config/gtk-3.0 ~/.config/micro ~/.config/polybar ~/.config/qBittorrent ~/.config/Thunar
mkdir -p ~/.fonts ~/.local/share/applications
sudo mkdir -p /etc/X11/xorg.conf.d

cp -rv ~/dotfiles-minti3/.config/i3/* ~/.config/i3/
cp -rv ~/dotfiles-minti3/.config/dunst/* ~/.config/dunst/
cp -rv ~/dotfiles-minti3/.config/rofi/* ~/.config/rofi/
cp -rv ~/dotfiles-minti3/.config/betterlockscreen/* ~/.config/betterlockscreen/
cp -rv ~/dotfiles-minti3/.config/bluetooth-connect/* ~/.config/bluetooth-connect/
cp -rv ~/dotfiles-minti3/.config/i3-logout/* ~/.config/i3-logout/
cp -rv ~/dotfiles-minti3/.config/geany/* ~/.config/geany/
cp -rv ~/dotfiles-minti3/.config/gtk-3.0/* ~/.config/gtk-3.0/
cp -rv ~/dotfiles-minti3/.config/micro/* ~/.config/micro/
cp -rv ~/dotfiles-minti3/.config/polybar/* ~/.config/polybar/
cp -rv ~/dotfiles-minti3/.config/qBittorrent/* ~/.config/qBittorrent/
cp -rv ~/dotfiles-minti3/.config/Thunar/* ~/.config/Thunar/
cp -rv ~/dotfiles-minti3/.fonts/* ~/.fonts/
cp -rv ~/dotfiles-minti3/.local/share/applications/* ~/.local/share/applications/
sudo cp -rv ~/dotfiles-minti3/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/
sudo cp -v ~/dotfiles-minti3/sddm.conf /etc/sddm.conf
cp -v ~/dotfiles-minti3/.bashrc ~/.bashrc
cp -v ~/dotfiles-minti3/.bashrc-personal ~/.bashrc-personal
cp -v ~/dotfiles-minti3/.fehbg ~/.fehbg
cp -v ~/dotfiles-minti3/.gtkrc-2.0.mine ~/.gtkrc-2.0.mine

# Section 12: Set Up Cron Jobs
echo "Setting up cron jobs..."
run_script "setup-cron-jobs.sh" true

# Ensure dunst is running for XFCE session
dunst &

# Section 13: Verify Installations
echo "Verifying installations..."
i3 --version
polybar --version
rofi --version > /dev/null 2>&1
dunst --version
i3lock-color --version
i3-logout --version
protonvpn-app --version
flatpak run io.github.shiftey.Desktop --version
vncserver-x11 --version
xfconf-query -c xsettings -p /Net/ThemeName
"$USER_HOME/i3ipc-venv/bin/pip" show i3ipc
cat /etc/sddm.conf.d/kde_settings.conf

echo "Mint i3 installation complete."