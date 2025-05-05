#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
BETTERLOCKSCREEN_DIR="$USER_HOME/github-repos/betterlockscreen"
OUTPUT_FILE="$USER_HOME/log-files/install-betterlockscreen/install-betterlockscreen-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-betterlockscreen
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check for git
echo "Checking for git..."
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    sudo apt-get install -y git
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install git. Exiting."
        exit 1
    fi
else
    echo "git is already installed."
fi

# Install dependencies
echo "Installing dependencies..."
sudo apt-get update
packages=(
    bc
    imagemagick
    libjpeg-turbo-progs
    x11-xserver-utils
    libpam0g-dev
    libxrandr-dev
    libev-dev
    libxcb-composite0
    libxcb-composite0-dev
    libxcb-xinerama0
    libxcb-randr0
    libxcb-util-dev
    libxcb-image0
    libxcb-image0-dev
    libxcb-xkb-dev
    libxkbcommon-x11-dev
    libcairo2-dev
    libfontconfig1-dev
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

# Clone or update Betterlockscreen repository
echo "Cloning or updating Betterlockscreen repository..."
if [ -d "$BETTERLOCKSCREEN_DIR/.git" ]; then
    echo "Betterlockscreen repository exists at $BETTERLOCKSCREEN_DIR, updating..."
    cd "$BETTERLOCKSCREEN_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update Betterlockscreen repository. Continuing."
    fi
else
    echo "Cloning Betterlockscreen repository..."
    git clone git@github.com:Sugarcrisp-ui/betterlockscreen.git "$BETTERLOCKSCREEN_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone Betterlockscreen repository. Exiting."
        exit 1
    fi
fi

# Install Betterlockscreen
echo "Installing Betterlockscreen..."
cd "$BETTERLOCKSCREEN_DIR"
if sudo bash install.sh system 2>/tmp/betterlockscreen-install-error.log; then
    echo "Betterlockscreen installed successfully."
else
    echo "Warning: Failed to install Betterlockscreen. Error details in /tmp/betterlockscreen-install-error.log."
    cat /tmp/betterlockscreen-install-error.log
fi

# Verify installation
echo "Verifying installation..."
if command -v betterlockscreen >/dev/null 2>&1; then
    echo "Betterlockscreen is installed: $(betterlockscreen --version 2>&1 | head -n 1)"
else
    echo "Warning: Betterlockscreen is not installed."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some operations may be restricted."
fi

echo "Betterlockscreen installation complete."
