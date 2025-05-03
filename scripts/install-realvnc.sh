#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
SERVER_DOWNLOAD_URL="https://downloads.realvnc.com/download/file/vnc.files/VNC-Server-7.13.0-Linux-x64.deb"
VIEWER_DOWNLOAD_URL="https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-7.13.0-Linux-x64.deb"
SERVER_DEB_FILE="$HOME/tmp/VNC-Server-7.13.0-Linux-x64.deb"
VIEWER_DEB_FILE="$HOME/tmp/VNC-Viewer-7.13.0-Linux-x64.deb"
OUTPUT_FILE="$HOME/github-repos/minti3/scripts/install-realvnc-output.txt"

# Redirect output to file
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Create temporary directory
echo "Creating temporary directory..."
mkdir -p "$HOME/tmp"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to create $HOME/tmp. Continuing."
fi

# Check and install dependencies
echo "Checking and installing dependencies..."
packages=(
    wget
    xterm
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

# Download RealVNC Server DEB package
echo "Downloading RealVNC Server..."
wget -O "$SERVER_DEB_FILE" "$SERVER_DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "$SERVER_DEB_FILE" ]; then
    echo "Warning: Failed to download RealVNC Server package. Continuing."
else
    # Install RealVNC Server
    echo "Installing RealVNC Server..."
    sudo dpkg -i "$SERVER_DEB_FILE"
    if [ $? -ne 0 ]; then
        echo "Attempting to fix dependencies for RealVNC Server..."
        sudo apt-get install -f -y
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install RealVNC Server or fix dependencies. Continuing."
        fi
    fi
fi

# Download RealVNC Viewer DEB package
echo "Downloading RealVNC Viewer..."
wget -O "$VIEWER_DEB_FILE" "$VIEWER_DOWNLOAD_URL"
if [ $? -ne 0 ] || [ ! -f "$VIEWER_DEB_FILE" ]; then
    echo "Warning: Failed to download RealVNC Viewer package. Continuing."
else
    # Install RealVNC Viewer
    echo "Installing RealVNC Viewer..."
    sudo dpkg -i "$VIEWER_DEB_FILE"
    if [ $? -ne 0 ]; then
        echo "Attempting to fix dependencies for RealVNC Viewer..."
        sudo apt-get install -f -y
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to install RealVNC Viewer or fix dependencies. Continuing."
        fi
    fi
fi

# Verify installation
echo "Verifying installation..."
if command -v vncserver-x11 >/dev/null 2>&1 && command -v vncviewer >/dev/null 2>&1; then
    echo "RealVNC Server and Viewer installed successfully."
else
    echo "Warning: RealVNC installation incomplete."
    ls -l /usr/bin/vnc* 2>/dev/null || echo "No VNC commands found."
fi

# Start and enable RealVNC Server service
echo "Configuring RealVNC Server service..."
if systemctl --version >/dev/null 2>&1; then
    sudo systemctl enable vncserver-x11-serviced 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to enable vncserver-x11-serviced. Continuing."
    fi
    sudo systemctl start vncserver-x11-serviced 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to start vncserver-x11-serviced. Continuing."
    fi
else
    echo "Warning: systemctl not found. Skipping VNC service configuration."
fi

# Clean up
echo "Cleaning up..."
rm -f "$SERVER_DEB_FILE" "$VIEWER_DEB_FILE"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to clean up temporary files."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). VNC functionality may be restricted."
fi

echo "RealVNC installation complete. Sign in with your RealVNC account to configure."
