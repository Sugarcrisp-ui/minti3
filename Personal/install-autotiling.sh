#!/bin/bash

# Install pipx
sudo apt install pipx -y

# Variables
USER="brett"
USER_HOME="/home/$USER"
VENV_DIR="$USER_HOME/i3ipc-venv"
DOTFILES_DIR="$USER_HOME/dotfiles-minti3"
AUTOTILING_SRC="$DOTFILES_DIR/Personal/autotiling.py"
AUTOTILING_DEST="$USER_HOME/.bin-personal/autotiling.py"

# Create and activate virtual environment
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

# Install i3ipc in virtual environment
pip install i3ipc

# Fetch autotiling script if not present in dotfiles
if [ ! -f "$AUTOTILING_SRC" ]; then
    echo "autotiling.py not found in $DOTFILES_DIR/Personal/, downloading from GitHub..."
    sudo -u "$USER" wget -O "$AUTOTILING_SRC" https://raw.githubusercontent.com/nwg-piotr/autotiling/main/autotiling.py
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download autotiling.py from GitHub"
        exit 1
    fi
fi

# Copy autotiling script
mkdir -p "$USER_HOME/.bin-personal"
cp "$AUTOTILING_SRC" "$AUTOTILING_DEST"
chmod +x "$AUTOTILING_DEST"

# Verify installation by checking file existence
if [ -f "$AUTOTILING_DEST" ]; then
    echo "autotiling.py installed successfully"
else
    echo "Error: autotiling.py installation failed"
    exit 1
fi

# Deactivate virtual environment
deactivate
