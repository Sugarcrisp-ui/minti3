#!/bin/bash

set -e

# Check if Discord is already installed
if dpkg -s discord &> /dev/null; then
    echo "Discord is already installed."
else
    # Download Discord .deb package
    wget -O discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"

    # Install Discord without prompts
    sudo dpkg -i discord.deb
    sudo apt install -y -f > /dev/null 2>&1

    # Clean up downloaded files
    rm discord.deb

    # Notify the user
    echo "Discord installation completed. You can now launch Discord from the application menu or by typing 'discord' in the terminal."
fi
