#!/bin/bash

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo"
    exit 1
fi

# Variables
USER_HOME="/home/brett"
REPO_URL="https://github.com/Raymo111/i3lock-color"
SRC_DIR="$USER_HOME/github-repos/i3lock-color"
OUTPUT_FILE="$USER_HOME/github-repos/minti3/scripts/update-i3lock-color-output.txt"
CRON_JOB="20 21 * * 0 /bin/bash $USER_HOME/github-repos/minti3/scripts/update-i3lock-color.sh >> $USER_HOME/github-repos/minti3/logs/i3lock-color-update.log 2>&1"

# Redirect output to file
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Install build dependencies
echo "Installing build dependencies..."
apt update
packages=(
    autoconf
    gcc
    make
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
    git
)
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Clone or update repository
echo "Cloning or updating i3lock-color repository..."
if [ -d "$SRC_DIR/.git" ]; then
    echo "i3lock-color repository exists at $SRC_DIR, updating..."
    cd "$SRC_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update i3lock-color repository. Continuing."
    fi
else
    echo "Cloning i3lock-color repository..."
    git clone "$REPO_URL" "$SRC_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3lock-color repository. Exiting."
        exit 1
    fi
fi

# Build and install
echo "Building and installing i3lock-color..."
cd "$SRC_DIR"
autoreconf -fi
if [ $? -ne 0 ]; then
    echo "Warning: Failed to run autoreconf. Continuing."
fi
mkdir -p build
cd build
../configure --enable-debug=no --disable-sanitizers
if [ $? -ne 0 ]; then
    echo "Warning: Failed to configure i3lock-color. Continuing."
fi
make
if [ $? -ne 0 ]; then
    echo "Warning: Failed to build i3lock-color. Continuing."
fi
make install
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

# Set up cron job
echo "Setting up cron job..."
if ! crontab -l 2>/dev/null | grep -F "$CRON_JOB" >/dev/null; then
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    if [ $? -eq 0 ]; then
        echo "Cron job added successfully."
    else
        echo "Warning: Failed to add cron job."
    fi
else
    echo "Cron job already exists."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some operations may be restricted."
fi

echo "i3lock-color update complete."
