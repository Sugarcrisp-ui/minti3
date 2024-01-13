#!/bin/bash

# Function to install a package if it's not already installed
install_package() {
  if ! pacman -Qs "$1" &> /dev/null; then
    echo -e "\e[32m###############################################################################\e[0m"
    echo -e "\e[32m################## Installing package $1\e[0m"
    echo -e "\e[32m###############################################################################\e[0m"
    echo
    sudo pacman -S --noconfirm --needed "$1"
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
  bluez
  bluez-utils
  bluez-libs
)

# Install packages
for package in "${packages[@]}"; do
  install_package "$package"
done

# Enable and start the Bluetooth service
if ! systemctl is-enabled bluetooth.service &> /dev/null; then
  sudo systemctl enable bluetooth.service
fi

if ! systemctl is-active bluetooth.service &> /dev/null; then
  sudo systemctl start bluetooth.service
fi

# Enable AutoEnable in /etc/bluetooth/main.conf
if ! grep -q "^AutoEnable=true" /etc/bluetooth/main.conf; then
  sudo sed -i 's/'#AutoEnable=false'/'AutoEnable=true'/g' /etc/bluetooth/main.conf
fi

# Final message
echo -e "\e[32m################################################################\e[0m"
echo -e "\e[32m################## Bluetooth software has been installed and enabled\e[0m"
echo -e "\e[32m################################################################\e[0m"
echo