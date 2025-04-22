#!/bin/bash

# Install pipx
sudo apt install pipx -y

# Create and activate virtual environment
python3 -m venv ~/i3ipc-venv
source ~/i3ipc-venv/bin/activate

# Install i3ipc in virtual environment
pip install i3ipc

# Copy autotiling script (assumes it's in ~/dotfiles/.bin-personal/)
mkdir -p ~/.bin-personal
cp ~/dotfiles/.bin-personal/autotiling.py ~/.bin-personal/autotiling.py
chmod +x ~/.bin-personal/autotiling.py

# Verify installation
~/i3ipc-venv/bin/python ~/.bin-personal/autotiling.py --version