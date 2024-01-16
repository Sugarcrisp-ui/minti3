#!/bin/bash
set -e

# Install pip
sudo apt install python3-pip

# Install autotiling using pip
pip3 install autotiling --user

# Output a message
echo "autotiling has been installed successfully!"
