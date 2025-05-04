#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
DBUS_ADDRESS="unix:path=/run/user/$(id -u "$USER")/bus"
OUTPUT_FILE="/home/brett/log-files/install-xfce-theme/install-xfce-theme-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-xfce-theme
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    arc-theme
    xfce4-settings
)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Check for xfconf-query
if ! command -v xfconf-query >/dev/null 2>&1; then
    echo "Warning: xfconf-query not found. Theme application may fail."
fi

# Apply Arc-Darker theme
echo "Applying Arc-Darker theme..."
if pgrep -u "$USER" xfce4-session >/dev/null || pgrep -u "$USER" i3 >/dev/null; then
    # Set xsettings theme
    if sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker" 2>/dev/null; then
        echo "Successfully set xsettings theme to Arc-Darker."
    else
        echo "Warning: Failed to set xsettings theme. Display may not be active."
    fi
    # Set xfwm4 theme
    if sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" xfconf-query -c xfwm4 -p /general/theme -s "Arc-Darker" 2>/dev/null; then
        echo "Successfully set xfwm4 theme to Arc-Darker."
    else
        echo "Warning: Failed to set xfwm4 theme. Display may not be active."
    fi
else
    echo "Warning: XFCE or i3 session not active. Skipping theme application."
fi

# Verify theme application
echo "Verifying theme application..."
THEME_SET=false
if sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" xfconf-query -c xsettings -p /Net/ThemeName 2>/dev/null | grep -q "Arc-Darker"; then
    echo "xsettings theme verified as Arc-Darker."
    THEME_SET=true
elif sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDRESS" xfconf-query -c xfwm4 -p /general/theme 2>/dev/null | grep -q "Arc-Darker"; then
    echo "xfwm4 theme verified as Arc-Darker."
    THEME_SET=true
else
    echo "Warning: Could not verify Arc-Darker theme application."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Theme application may be restricted."
    if [ "$THEME_SET" = false ]; then
        echo "Note: Theme verification likely failed due to Docker environment."
    fi
fi

echo "XFCE theme installation complete."
