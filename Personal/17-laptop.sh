#!/bin/bash

set -e

# Function to install a package if it's not already installed
install_package() {
  if ! dpkg -l "$1" &> /dev/null; then
    echo -e "\e[32m###############################################################################\e[0m"
    echo -e "\e[32m################## Installing package $1\e[0m"
    echo -e "\e[32m###############################################################################\e[0m"
    echo
    sudo apt-get install -y "$1"
  else
    echo -e "\e[32m###############################################################################\e[0m"
    echo -e "\e[32m################## The package $1 is already installed\e[0m"
    echo -e "\e[32m###############################################################################\e[0m"
    echo
  fi
}

# Function to handle errors
handle_error() {
  echo -e "\e[31mAn error occurred while installing the packages. Please check the output and try again.\e[0m"
  exit 1
}

# Set up error handling
trap 'handle_error' ERR

# List of packages to install
packages=(
  tlp
)

# Install packages
for package in "${packages[@]}"; do
  install_package "$package"
done

# Enable the TLP service
sudo systemctl enable tlp.service

# Final message
echo -e "\e[32m################################################################\e[0m"
echo -e "\e[32m################## Laptop software has been installed\e[0m"
echo -e "\e[32m################################################################\e[0m"
echo
