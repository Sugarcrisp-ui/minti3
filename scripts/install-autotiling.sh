#!/bin/bash

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME="$HOME"
VENV_DIR="$USER_HOME/i3ipc-venv"
AUTOTILING_DIR="$USER_HOME/autotiling"
OUTPUT_FILE="$USER_HOME/log-files/install-autotiling/install-autotiling-output.txt"

# Redirect output to file
mkdir -p ~/log-files/install-autotiling
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

echo "Checking for Python, pip, and venv..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 not found. Exiting."
    exit 1
fi
packages=("python3-pip" "python3-venv")
for pkg in "${packages[@]}"; do
    if ! dpkg -l | grep -q " $pkg "; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install $pkg. Exiting."
            exit 1
        fi
    else
        echo "$pkg is already installed."
    fi
done

# Check for virtual environment
echo "Checking for virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    echo "Warning: Virtual environment not found at $VENV_DIR. Creating one..."
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment at $VENV_DIR. Exiting."
        exit 1
    fi
fi

# Install i3ipc in virtual environment
echo "Installing i3ipc in virtual environment..."
source "$VENV_DIR/bin/activate"
if [ $? -ne 0 ]; then
    echo "Warning: Failed to activate virtual environment. Recreating..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to recreate virtual environment at $VENV_DIR. Exiting."
        exit 1
    fi
    source "$VENV_DIR/bin/activate"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to activate recreated virtual environment. Exiting."
        exit 1
    fi
fi
pip install --upgrade pip
pip install i3ipc==2.2.1
if [ $? -ne 0 ]; then
    echo "Warning: Failed to install i3ipc in virtual environment. Continuing."
    deactivate
else
    echo "i3ipc installed successfully."
    deactivate
fi

# Clone or update autotiling repository
echo "Cloning or updating autotiling repository..."
if [ -d "$AUTOTILING_DIR/.git" ]; then
    echo "autotiling repository exists at $AUTOTILING_DIR, updating..."
    cd "$AUTOTILING_DIR"
    git pull
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to update autotiling repository. Continuing with existing version."
    fi
else
    echo "Cloning autotiling repository..."
    git clone https://github.com/Sugarcrisp-ui/autotiling.git "$AUTOTILING_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone autotiling repository. Exiting."
        exit 1
    fi
fi

# Install autotiling
echo "Installing autotiling..."
if [ -f "$AUTOTILING_DIR/autotiling.py" ]; then
    sudo cp "$AUTOTILING_DIR/autotiling.py" /usr/local/bin/autotiling.py
    if [ $? -ne 0 ]; then
        echo "Warning: Failed to copy autotiling.py to /usr/local/bin/. Continuing."
    else
        sudo chmod +x /usr/local/bin/autotiling.py
        if [ $? -ne 0 ]; then
            echo "Warning: Failed to set executable permissions on autotiling.py. Continuing."
        fi
    fi
else
    echo "Error: autotiling.py not found in $AUTOTILING_DIR. Exiting."
    exit 1
fi

# Verify installation
echo "Verifying installation..."
if [ -x /usr/local/bin/autotiling.py ]; then
    echo "autotiling.py is installed and executable."
else
    echo "Warning: autotiling.py not installed or not executable."
fi

# Check for Docker environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Network operations (e.g., git clone) or system permissions may be restricted."
fi

echo "autotiling installation complete."
