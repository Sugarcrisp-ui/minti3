#!/bin/bash

# Change directory to the scripts' location
cd "$(dirname "$0")/Personal"

# Set execute permission on all .sh files
chmod +x *.sh

# Install scripts in numerical order
for script in $(ls -v *.sh); do
    ./$script
done

# Ask to restart the system
read -p "Installation complete. Restart now? (y/n): " choice
if [ "$choice" == "y" ]; then
    sudo reboot
fi
