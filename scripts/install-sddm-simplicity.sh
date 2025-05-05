#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
THEMES_DIR="$HOME/tmp/sddm-themes"
OUTPUT_FILE="$USER_HOME/log-files/install-sddm-simplicity/install-sddm-simplicity-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-sddm-simplicity
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    sddm
    libqt5quickcontrols2-5
    qml-module-qtquick-controls
    qml-module-qtquick-controls2
    git
)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        echo "sddm shared/default-x-display-manager select sddm" | sudo debconf-set-selections
        echo "keyboard-configuration keyboard-configuration/layoutcode string us" | sudo debconf-set-selections
        echo "keyboard-configuration keyboard-configuration/variantcode string" | sudo debconf-set-selections
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Create user-specific temporary directory
mkdir -p "$HOME/tmp"
echo "Created $HOME/tmp directory."

# Clone or update sddm-themes repository
echo "Cloning or updating sddm-themes repository..."
if [ -d "$THEMES_DIR/.git" ]; then
    echo "sddm-themes repository exists at $THEMES_DIR, updating..."
    cd "$THEMES_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update sddm-themes repository. Continuing."
    fi
else
    echo "Cloning sddm-themes repository..."
    git clone https://github.com/Sugarcrisp-ui/sddm-themes.git "$THEMES_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone sddm-themes repository. Exiting."
        exit 1
    fi
fi

# Install the sddm-simplicity theme
echo "Installing sddm-simplicity theme..."
if [ -d "$THEMES_DIR/sddm-simplicity" ]; then
    sudo cp -r "$THEMES_DIR/sddm-simplicity" /usr/share/sddm/themes/
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to install sddm-simplicity theme. Continuing."
    fi
else
    echo "Warning: sddm-simplicity theme not found in $THEMES_DIR. Continuing."
fi

# Configure SDDM to use the sddm-simplicity theme
echo "Configuring SDDM to use sddm-simplicity theme..."
sudo mkdir -p /etc/sddm.conf.d
echo "[Theme]" | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null
echo "Current=sddm-simplicity" | sudo tee -a /etc/sddm.conf.d/theme.conf >/dev/null
if [ $? -ne 0 ]; then
    echo "Warning: Failed to configure SDDM to use sddm-simplicity theme. Continuing."
fi

# Verify installation
echo "Verifying installation..."
if grep -q "Current=sddm-simplicity" /etc/sddm.conf.d/theme.conf && [ -d "/usr/share/sddm/themes/sddm-simplicity" ]; then
    echo "SDDM is configured to use sddm-simplicity theme."
else
    echo "Warning: SDDM configuration or theme installation failed."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some operations may be restricted."
fi

echo "SDDM and sddm-simplicity theme installation complete."
