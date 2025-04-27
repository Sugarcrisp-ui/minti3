#!/bin/bash

USER=$(whoami)

echo "Installing i3 autotiling..."
sudo apt-get update
sudo apt-get install -y python3-pip

/home/$USER/i3ipc-venv/bin/pip install i3ipc
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3ipc. Exiting."
    exit 1
fi

if [ -d "/home/$USER/autotiling/.git" ]; then
    echo "autotiling repository already exists at /home/$USER/autotiling, updating..."
    cd /home/$USER/autotiling
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update autotiling repository. Exiting."
        exit 1
    fi
else
    echo "Cloning autotiling repository..."
    git clone https://github.com/Sugarcrisp-ui/autotiling.git /home/$USER/autotiling
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone autotiling repository. Exiting."
        exit 1
    fi
fi

if [ -f "/home/$USER/autotiling/autotiling.py" ]; then
    echo "Installing autotiling..."
    sudo cp /home/$USER/autotiling/autotiling.py /usr/local/bin/autotiling.py
    sudo chmod +x /usr/local/bin/autotiling.py
else
    echo "Error: autotiling.py not found. Exiting."
    exit 1
fi

echo "autotiling installation complete."
