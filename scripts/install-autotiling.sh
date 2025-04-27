#!/bin/bash

# Install dependencies
sudo apt-get install -y pipx
if [ $? -ne 0 ]; then
    echo "Error: Failed to install pipx. Exiting."
    exit 1
fi

# Ensure i3ipc is installed
echo "Installing i3ipc in virtual environment..."
/home/testuser/i3ipc-venv/bin/pip install i3ipc
if [ $? -ne 0 ]; then
    echo "Error: Failed to install i3ipc. Exiting."
    exit 1
fi

# Clone or update autotiling repository
if [ -d "/home/testuser/autotiling/.git" ]; then
    echo "autotiling repository already exists at /home/testuser/autotiling, updating..."
    cd /home/testuser/autotiling
    git pull
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update autotiling repository. Exiting."
        exit 1
    fi
else
    echo "Cloning autotiling repository..."
    git clone https://github.com/Sugarcrisp-ui/autotiling.git /home/testuser/autotiling
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone autotiling repository. Exiting."
        exit 1
    fi
fi

# Copy autotiling.py to /usr/local/bin/ with sudo
if [ -f "/home/testuser/autotiling/autotiling.py" ]; then
    sudo cp /home/testuser/autotiling/autotiling.py /usr/local/bin/autotiling.py
    if [ $? -ne 0 ]; then
        echo "Error: Failed to copy autotiling.py to /usr/local/bin/. Exiting."
        exit 1
    fi
    sudo chmod +x /usr/local/bin/autotiling.py
    if [ $? -ne 0 ]; then
        echo "Error: Failed to set execute permissions on /usr/local/bin/autotiling.py. Exiting."
        exit 1
    fi
    echo "autotiling.py installed successfully"
else
    echo "Error: autotiling.py not found in repository. Exiting."
    exit 1
fi
