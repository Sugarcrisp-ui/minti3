#!/bin/bash

# Script to install i3ipc in a virtual environment on Linux Mint

# Variables
USER=$(whoami)
USER_HOME="/home/$USER"
VENV_DIR="$USER_HOME/i3ipc-venv"

# Install dependencies
echo "Installing dependencies..."
sudo apt update
if [ $? -ne 0 ]; then
    echo "Error: Failed to update package lists. Exiting."
    exit 1
fi
sudo apt install -y python3-venv python3-pip
if [ $? -ne 0 ]; then
    echo "Error: Failed to install Python dependencies. Exiting."
    exit 1
fi

# Create and set up virtual environment
echo "Creating virtual environment..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment at $VENV_DIR. Exiting."
        exit 1
    fi
fi

# Activate virtual environment and install i3ipc
echo "Installing i3ipc..."
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
if [ $? -ne 0 ]; then
    echo "Error: Failed to upgrade pip in virtual environment. Exiting."
    deactivate
    exit 1
fi
pip install i3ipc
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3ipc in virtual environment. Exiting."
    deactivate
    exit 1
fi
deactivate

# Verify installation
if "$VENV_DIR/bin/pip" show i3ipc >/dev/null; then
    echo "i3ipc installed successfully"
else
    echo "Error: i3ipc installation failed. Exiting."
    exit 1
fi

echo "i3ipc installation complete."
