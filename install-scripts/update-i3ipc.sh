#!/bin/bash

# Script to update i3ipc in ~/i3ipc-venv/ on Linux Mint

# Variables
VENV_DIR="$HOME/i3ipc-venv"
PIP="$VENV_DIR/bin/pip"
LOG_FILE="$HOME/minti3/Personal/i3ipc-update.log"

# Check if virtual environment exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Error: Virtual environment $VENV_DIR not found" >> "$LOG_FILE"
    exit 1
fi

# Activate virtual environment
source "$VENV_DIR/bin/activate"

# Update pip and i3ipc
echo "Updating i3ipc $(date)" >> "$LOG_FILE"
$PIP install --upgrade pip >> "$LOG_FILE" 2>&1
$PIP install --upgrade i3ipc >> "$LOG_FILE" 2>&1

# Check if update was successful
if [ $? -eq 0 ]; then
    echo "i3ipc updated successfully" >> "$LOG_FILE"
else
    echo "Error: Failed to update i3ipc" >> "$LOG_FILE"
    exit 1
fi

# Deactivate virtual environment
deactivate

echo "i3ipc update complete" >> "$LOG_FILE"
