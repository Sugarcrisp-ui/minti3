#!/bin/bash

# Script to update i3ipc in ~/i3ipc-venv/ on Linux Mint

# Ensure script is run as non-root user
USER=$(whoami)
if [ "$USER" = "root" ]; then
    echo "Error: This script should not be run as root. Exiting."
    exit 1
fi

# Variables
USER_HOME=$(eval echo ~$USER)
VENV_DIR="$USER_HOME/i3ipc-venv"
PIP="$VENV_DIR/bin/pip"
LOG_DIR="$USER_HOME/log-files/update-i3ipc"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="$LOG_DIR/update-i3ipc-$TIMESTAMP.txt"

# Redirect output to timestamped log file
mkdir -p "$LOG_DIR"
exec > >(tee -a "$OUTPUT_FILE") 2>&1
echo "Logging output to $OUTPUT_FILE"

# Check if virtual environment exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Virtual environment $VENV_DIR not found"
    exit 1
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Update pip and i3ipc
echo "Updating i3ipc $(date)"
$PIP install --upgrade pip
if [ $? -eq 0 ]; then
    echo "pip updated successfully"
else
    echo "Error: Failed to update pip"
    exit 1
fi
$PIP install --upgrade i3ipc
if [ $? -eq 0 ]; then
    echo "i3ipc updated successfully"
else
    echo "Error: Failed to update i3ipc"
    exit 1
fi

# Deactivate virtual environment
deactivate

echo "i3ipc update complete"
