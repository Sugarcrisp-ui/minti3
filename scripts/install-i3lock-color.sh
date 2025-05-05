#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
GITHUB_REPOS_DIR="$USER_HOME/github-repos"
I3LOCK_COLOR_DIR="$GITHUB_REPOS_DIR/i3lock-color"
OUTPUT_FILE="$USER_HOME/log-files/install-i3lock-color/install-i3lock-color-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-i3lock-color
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

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    autoconf
    automake
    pkg-config
    libpam0g-dev
    libcairo2-dev
    libfontconfig1-dev
    libxcb-composite0-dev
    libev-dev
    libx11-xcb-dev
    libxcb-xkb-dev
    libxcb-xinerama0-dev
    libxcb-randr0-dev
    libxcb-image0-dev
    libxcb-util-dev
    libxcb-xrm-dev
    libxkbcommon-dev
    libxkbcommon-x11-dev
    libjpeg-dev
    libgif-dev
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

# Clone or update i3lock-color repository
echo "Cloning or updating i3lock-color repository..."
if [ -d "$I3LOCK_COLOR_DIR/.git" ]; then
    echo "i3lock-color repository exists at $I3LOCK_COLOR_DIR, updating..."
    cd "$I3LOCK_COLOR_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update i3lock-color repository. Continuing with existing version."
    fi
else
    echo "Cloning i3lock-color repository..."
    git clone https://github.com/Raymo111/i3lock-color.git "$I3LOCK_COLOR_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3lock-color repository. Exiting."
        exit 1
    fi
fi

# Build and install i3lock-color
echo "Building and installing i3lock-color..."
cd "$I3LOCK_COLOR_DIR"
autoreconf -fi
if [ $? -ne 0 ]; then
    echo "Warning: Failed to run autoreconf. Continuing."
fi
mkdir -p build
cd build
../configure
if [ $? -ne 0 ]; then
    echo "Warning: Failed to configure i3lock-color. Continuing."
fi
make
if [ $? -ne 0 ]; then
    echo "Warning: Failed to build i3lock-color. Continuing."
fi
sudo make install
if [ $? -ne 0 ]; then
    echo "Warning: Failed to install i3lock-color. Continuing."
fi

# Verify installation
echo "Verifying installation..."
if command -v i3lock >/dev/null 2>&1; then
    echo "i3lock-color is installed: $(i3lock --version 2>&1 | head -n 1)"
else
    echo "Warning: i3lock-color is not installed."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some operations (e.g., building i3lock-color) may be restricted."
fi

echo "i3lock-color installation complete."
