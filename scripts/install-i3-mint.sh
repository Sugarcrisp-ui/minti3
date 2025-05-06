#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
LOG_DIR="$USER_HOME/log-files/install-i3-mint"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-i3-mint-$TIMESTAMP.txt"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    i3
    i3status
    rofi
    dunst
    xfce4-terminal
    micro
    polybar
    build-essential
    cmake
    libjsoncpp-dev
    libxcb-randr0-dev
    libxcb-xinerama0-dev
    libxcb-util-dev
    libxcb-icccm4-dev
    libiw-dev
    copyq
    blueman
    pasystray
)
unavailable_packages=(
    libiw-dev  # May be replaced by wireless-tools or libiw30 in some distros
)

for pkg in "${unavailable_packages[@]}"; do
    echo "Warning: Package $pkg may not be available in Linux Mint repositories. Skipping."
done

for pkg in "${packages[@]}"; do
    if [[ " ${unavailable_packages[*]} " =~ " $pkg " ]]; then
        continue
    fi
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

# Create configuration directories
echo "Creating configuration directories..."
mkdir -p "$USER_HOME/.config/i3" "$USER_HOME/.config/rofi" "$USER_HOME/.config/dunst" "$USER_HOME/.bin-personal"
echo "Configuration directories created."

# Verify installations
echo "Verifying installations..."
verified_commands=(
    i3
    polybar
    rofi
    dunst
)
for cmd in "${verified_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        if [ "$cmd" = "rofi" ]; then
            echo "$cmd is installed: $(rofi --version > /dev/null 2>&1 && echo 'version check passed')"
        else
            echo "$cmd is installed: $($cmd --version 2>&1 | head -n 1)"
        fi
    else
        echo "Warning: $cmd is not installed."
    fi
done

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some packages (e.g., blueman, pasystray) may not function fully."
fi

echo "i3-mint installation complete."
