#!/bin/bash

set -e

# Function to display text in green
print_green() {
    echo -e "\e[32m$1\e[0m"
}

# Install i3 window manager and Polybar
echo -e "\e[32mInstalling i3 and Polybar...\e[0m"
sudo apt install i3 polybar -y

print_green "Polybar has been successfully installed."
