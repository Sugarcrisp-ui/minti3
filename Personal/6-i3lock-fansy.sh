#!/bin/bash
set -e

# Check if i3lock-fancy is already installed
if command -v i3lock-fancy &> /dev/null
then
    echo "i3lock-fancy is already installed."
else
    # Install i3lock-fancy
    git clone https://github.com/meskarune/i3lock-fancy.git
    cd i3lock-fancy
    sudo make install

    # Clean up installation files
    cd ..
    rm -rf i3lock-fancy

    # Create i3lock-fancy directory and configuration file if they don't exist
    mkdir -p ~/.config/i3lock-fancy
    touch ~/.config/i3lock-fancy/lock

    # Update i3lock-fancy configuration
    sed -i 's/# default/rm -f "$IMAGE" \&\& /' ~/.config/i3lock-fancy/lock
    echo "i3lock-fancy installation complete."
fi
