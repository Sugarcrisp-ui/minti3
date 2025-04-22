#!/bin/bash

# Script to install i3ipc in a virtual environment on Linux Mint

# Variables
USER="brett"
USER_HOME="/home/$USER"
VENV_DIR="$USER_HOME/i3ipc-venv"

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y python3-venv python3-pip

# Create and set up virtual environment
echo "Creating virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment and install i3ipc
echo "Installing i3ipc..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install i3ipc
deactivate

# Verify installation
if "$VENV_DIR/bin/pip" show i3ipc >/dev/null; then
    echo "i3ipc installed successfully"
else
    echo "Error: i3ipc installation failed"
    exit 1
fi

echo "i3ipc installation complete."
