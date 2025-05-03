#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
USER_CONFIGS_DIR="$USER_HOME/github-repos/user-configs"
I3_LOGOUT_DIR="$USER_HOME/github-repos/i3-logout"
OUTPUT_FILE="$USER_HOME/github-repos/minti3/scripts/install-i3-logout-output.txt"

# Redirect output to file
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check for Python
echo "Checking for Python..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found. Exiting."
    exit 1
fi

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    python3
    python3-gi
    gir1.2-wnck-3.0
    python3-psutil
    python3-cairo
    python3-distro
    git
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

# Clone or update i3-logout repository
echo "Cloning or updating i3-logout repository..."
if [ -d "$I3_LOGOUT_DIR/.git" ]; then
    echo "i3-logout repository exists at $I3_LOGOUT_DIR, updating..."
    cd "$I3_LOGOUT_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update i3-logout repository. Continuing."
    fi
else
    echo "Cloning i3-logout repository..."
    git clone https://github.com/Sugarcrisp-ui/i3-logout.git "$I3_LOGOUT_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone i3-logout repository. Exiting."
        exit 1
    fi
fi

# Ensure i3-logout.py, GUI.py, and Functions.py exist
echo "Checking for Python files..."
for file in i3-logout.py GUI.py Functions.py; do
    if [ ! -f "$I3_LOGOUT_DIR/$file" ]; then
        echo "Error: $file not found in $I3_LOGOUT_DIR/. Exiting."
        exit 1
    fi
done

# Update i3-logout.py to remove archlinux references
echo "Updating i3-logout.py to remove archlinux references..."
sed -i 's/archlinux-logout/i3-logout/g' "$I3_LOGOUT_DIR/i3-logout.py"
sed -i 's/archlinux-betterlockscreen/betterlockscreen/g' "$I3_LOGOUT_DIR/i3-logout.py"
sed -i 's/Archlinux Logout/i3-logout/g' "$I3_LOGOUT_DIR/i3-logout.py"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to update i3-logout.py. Continuing."
fi

# Install config from user-configs/backup.latest
echo "Installing config..."
LATEST_BACKUP=""
BACKUP_LINK="$USER_CONFIGS_DIR/backup.latest"
if [ -L "$BACKUP_LINK" ] && [ -d "$(readlink -f "$BACKUP_LINK")" ]; then
    LATEST_BACKUP=$(readlink -f "$BACKUP_LINK")
else
    echo "Warning: No valid backup.latest link found at $BACKUP_LINK. Skipping config installation."
fi
CONFIG_FILE="$LATEST_BACKUP/.config/i3-logout/i3-logout.conf"
if [ -f "$CONFIG_FILE" ]; then
    echo "Installing $CONFIG_FILE to /etc/i3-logout.conf"
    sudo install -Dm644 "$CONFIG_FILE" /etc/i3-logout.conf
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to install $CONFIG_FILE to /etc/i3-logout.conf. Continuing."
    fi
else
    echo "Warning: i3-logout.conf not found at $CONFIG_FILE. Continuing."
fi

# Install binaries
echo "Installing binaries..."
sudo install -Dm755 "$I3_LOGOUT_DIR/i3-logout.py" /usr/bin/i3-logout
if [ $? -ne 0 ]; then
    echo "Warning: Failed to install i3-logout.py to /usr/bin/i3-logout. Continuing."
fi

# Install Python files
echo "Installing Python files..."
sudo mkdir -p /usr/share/i3-logout
sudo install -Dm644 "$I3_LOGOUT_DIR/GUI.py" /usr/share/i3-logout/GUI.py
sudo install -Dm644 "$I3_LOGOUT_DIR/Functions.py" /usr/share/i3-logout/Functions.py
if [ $? -ne 0 ]; then
    echo "Warning: Failed to install Python files to /usr/share/i3-logout/. Continuing."
fi

# Install themes
echo "Installing themes..."
sudo mkdir -p /usr/share/i3-logout-themes/themes
if [ -d "$I3_LOGOUT_DIR/themes" ]; then
    sudo cp -r "$I3_LOGOUT_DIR/themes/"* /usr/share/i3-logout-themes/themes/
    sudo cp "$I3_LOGOUT_DIR"/*.svg /usr/share/i3-logout-themes/ 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to install some themes to /usr/share/i3-logout-themes/. Continuing."
    fi
else
    echo "Warning: Themes directory not found in $I3_LOGOUT_DIR. Skipping theme installation."
fi

# Verify installation
echo "Verifying installation..."
if command -v i3-logout >/dev/null 2>&1; then
    echo "i3-logout is installed and executable."
else
    echo "Warning: i3-logout is not installed or not executable."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Some operations may be restricted."
fi

echo "i3-logout installation complete."
