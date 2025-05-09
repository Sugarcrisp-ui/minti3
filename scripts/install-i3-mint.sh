#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not #!/bin/bash
    
    # Ensure script is run as non-root user
    USER=$(whoami)
    if [ "$USER" = "root" ]; then
        echo "Error: This script should not be run as root. Exiting."
        exit 1
    fi
    
    # Variables
    HOME="/home/brett"
    LOG_DIR="$HOME/log-files/install-i3-mint"
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    OUTPUT_FILE="$LOG_DIR/install-i3-mint-$TIMESTAMP.txt"
    
    # Redirect output to timestamped log file and terminal
    mkdir -p "$LOG_DIR"
    exec > >(tee -a "$OUTPUT_FILE") 2>&1
    echo "Logging output to $OUTPUT_FILE"
    
    # Update package lists once
    echo "Updating package lists..."
    sudo apt-get update -y
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update package lists. Continuing."
    fi
    
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
        copyq
        blueman
        pasystray
    )
    unavailable_packages=(
        libiw-dev
    )
    for pkg in "${unavailable_packages[@]}"; do
        echo "Warning: Package $pkg may not be available in Linux Mint repositories. Skipping."
    done
    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q " $pkg "; then
            echo "Installing $pkg..."
            sudo apt-get install -y --no-install-recommends "$pkg"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to install $pkg. Continuing."
            fi
        else
            echo "$pkg is already installed."
        fi
    done
    
    # Create configuration directories
    echo "Creating configuration directories..."
    mkdir -p "$HOME/.config/i3" "$HOME/.config/polybar" "$HOME/.config/rofi" "$HOME/.config/dunst"
    if [ $? -eq 0 ]; then
        echo "Configuration directories created."
    else
        echo "Warning: Failed to create configuration directories."
    fi
    
    # Verify installations
    echo "Verifying installations..."
    if command -v i3 >/dev/null; then
        echo "i3 is installed: $(i3 --version)"
    else
        echo "Warning: i3 is not installed."
    fi
    if command -v polybar >/dev/null; then
        echo "polybar is installed: $(polybar --version)"
    else
        echo "Warning: polybar is not installed."
    fi
    if command -v rofi >/dev/null; then
        echo "rofi is installed: $(rofi -v)"
    else
        echo "Warning: rofi is not installed."
    fi
    if command -v dunst >/dev/null; then
        echo "dunst is installed: $(dunst -v)"
    else
        echo "Warning: dunst is not installed."
    fi
    
    echo "i3-mint installation complete."be run as root. Exiting."
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
    copyq
    blueman
    pasystray
)
unavailable_packages=(
    libiw-dev
)
for pkg in "${unavailable_packages[@]}"; do
    echo "Warning: Package $pkg may not be available in Linux Mint repositories. Skipping."
done
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Continuing."
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Create configuration directories
echo "Creating configuration directories..."
mkdir -p "$USER_HOME/.config/i3" "$USER_HOME/.config/polybar" "$USER_HOME/.config/rofi" "$USER_HOME/.config/dunst"
if [ $? -eq 0 ]; then
    echo "Configuration directories created."
else
    echo "Warning: Failed to create configuration directories."
fi

# Verify installations
echo "Verifying installations..."
if command -v i3 >/dev/null; then
    echo "i3 is installed: $(i3 --version)"
else
    echo "Warning: i3 is not installed."
fi
if command -v polybar >/dev/null; then
    echo "polybar is installed: $(polybar --version)"
else
    echo "Warning: polybar is not installed."
fi
if command -v rofi >/dev/null; then
    echo "rofi is installed: $(rofi -v)"
else
    echo "Warning: rofi is not installed."
fi
if command -v dunst >/dev/null; then
    echo "dunst is installed: $(dunst -v)"
else
    echo "Warning: dunst is not installed."
fi

echo "i3-mint installation complete."
