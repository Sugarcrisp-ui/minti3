#!/bin/bash
# install-autotiling.sh
# Purpose: Install autotiling and i3ipc for i3 window manager, using a virtual environment.
# Usage: Run `./install-autotiling.sh` in warp-terminal.
# Dependencies: git, python3, python3-pip, python3-venv.
# Notes:
# - Installs i3ipc in ~/i3ipc-venv to handle PEP 668 restrictions.
# - Places autotiling in ~/.bin-personal/ and adds to i3 config for brett-K501UX.
# - Logs to ~/log-files/install-autotiling/<timestamp>.txt.
# - Tailored for Linux Mint with i3/Polybar.
# Author: Brett Crisp (brettcrisp2@gmail.com)

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
VENV_DIR="$USER_HOME/i3ipc-venv"
AUTOTILING_DIR="$USER_HOME/autotiling"
PERSONAL_BIN="$USER_HOME/.bin-personal"
LOG_DIR="$USER_HOME/log-files/install-autotiling"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/install-autotiling-$TIMESTAMP.txt"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check for git
echo "Checking for git..."
if ! command -v git >/dev/null 2>&1; then
    echo "Installing git..."
    sudo apt-get install -y git || { echo "Error: Failed to install git. Exiting."; exit 1; }
else
    echo "git is already installed."
fi

# Check for Python, pip, and venv
echo "Checking for Python, pip, and venv..."
packages=("python3" "python3-pip" "python3-venv")
for pkg in "${packages[@]}"; do
    if ! command -v ${pkg%-*} >/dev/null 2>&1; then
        echo "Installing $pkg..."
        sudo apt-get install -y "$pkg" || { echo "Error: Failed to install $pkg. Exiting."; exit 1; }
    else
        echo "$pkg is already installed."
    fi
done

# Create virtual environment
echo "Checking for virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR" || { echo "Error: Failed to create virtual environment. Exiting."; exit 1; }
fi

# Install i3ipc in virtual environment
echo "Installing i3ipc in virtual environment..."
source "$VENV_DIR/bin/activate" || { echo "Error: Failed to activate virtual environment. Exiting."; exit 1; }
pip install --upgrade pip || { echo "Error: Failed to upgrade pip. Exiting."; deactivate; exit 1; }
pip install i3ipc==2.2.1 || { echo "Error: Failed to install i3ipc. Exiting."; deactivate; exit 1; }
echo "i3ipc installed successfully."
deactivate

# Clone or update autotiling repository
echo "Cloning or updating autotiling repository..."
if [ -d "$AUTOTILING_DIR/.git" ]; then
    echo "autotiling repository exists at $AUTOTILING_DIR, updating..."
    cd "$AUTOTILING_DIR" && git pull || echo "Warning: Failed to update autotiling repository. Continuing."
else
    echo "Cloning autotiling repository..."
    git clone https://github.com/Sugarcrisp-ui/autotiling.git "$AUTOTILING_DIR" || { echo "Error: Failed to clone autotiling repository. Exiting."; exit 1; }
fi

# Install autotiling to ~/.bin-personal/
echo "Installing autotiling..."
mkdir -p "$PERSONAL_BIN"
if [ -f "$AUTOTILING_DIR/autotiling.py" ]; then
    cp "$AUTOTILING_DIR/autotiling.py" "$PERSONAL_BIN/autotiling" || { echo "Error: Failed to copy autotiling to $PERSONAL_BIN. Exiting."; exit 1; }
    chmod +x "$PERSONAL_BIN/autotiling" || { echo "Error: Failed to set executable permissions on autotiling. Exiting."; exit 1; }
    # Update shebang to use virtual environment's Python
    sed -i "1s|^.*$|#!$VENV_DIR/bin/python3|" "$PERSONAL_BIN/autotiling"
else
    echo "Error: autotiling.py not found in $AUTOTILING_DIR. Exiting."
    exit 1
fi

# Add autotiling to i3 config for laptop
echo "Configuring i3 to run autotiling on brett-K501UX..."
I3_CONFIG="$USER_HOME/.config/i3/config"
AUTOTILING_LINE='exec --no-startup-id bash -c "[ \"$(hostname)\" = \"brett-K501UX\" ] && ~/.bin-personal/autotiling"'
if ! grep -Fx "$AUTOTILING_LINE" "$I3_CONFIG" >/dev/null; then
    echo "$AUTOTILING_LINE" >> "$I3_CONFIG" || { echo "Error: Failed to update i3 config. Exiting."; exit 1; }
    i3-msg reload || echo "Warning: Failed to reload i3. Run 'i3-msg reload' manually."
fi

# Verify installation
echo "Verifying installation..."
if [ -x "$PERSONAL_BIN/autotiling" ]; then
    echo "autotiling is installed and executable in $PERSONAL_BIN."
    "$PERSONAL_BIN/autotiling" --version >/dev/null 2>&1 && echo "autotiling runs successfully." || echo "Warning: autotiling failed to run."
else
    echo "Error: autotiling not installed or not executable. Exiting."
    exit 1
fi

# Check for containerized environment
if [ -f "/proc/1/cgroup" ] && grep -qE "docker|containerd|kubepods|libpod|/docker/|/.*/docker/|/.*/containerd/" /proc/1/cgroup || [ -f "/.dockerenv" ]; then
    echo "Warning: Running in a containerized environment (Docker). Network operations or permissions may be restricted."
fi

echo "autotiling installation complete."
