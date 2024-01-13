#!/bin/bash

# Get Linux Mint version
mint_version=$(cat /etc/os-release | grep VERSION_ID | cut -d= -f2 | tr -d '"')

# Determine the corresponding Ubuntu version
case $mint_version in
    "19.3") ubuntu_version="tricia" ;;
    "20") ubuntu_version="ulyana" ;;
    "20.1") ubuntu_version="ulyssa" ;;
    "20.2") ubuntu_version="uma" ;;
    "20.3") ubuntu_version="una" ;;
    "21" | "21.1" | "21.2") ubuntu_version="jammy" ;;
    *) echo "Unsupported Linux Mint version: $mint_version"; exit 1 ;;
esac

# Download Insync
insync_url="https://cdn.insynchq.com/builds/linux/insync_3.8.7.50516-${ubuntu_version}_amd64.deb"
wget "$insync_url" -O insync.deb

# Check if the download was successful
if [ $? -eq 0 ]; then
    # Install Insync unattended
    sudo dpkg -i --force-confold --force-confdef insync.deb
    sudo apt-get install -f -y

    # Cleanup
    rm insync.deb
    echo "Cleanup complete."
else
    echo "Failed to download Insync package. Please check your internet connection or try again later."
fi
