#!/bin/bash

# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y build-essential dkms

# Download and add Oracle VirtualBox repository key
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -

# Add the VirtualBox repository to the system
sudo add-apt-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"

# Update package lists again
sudo apt update

# Install VirtualBox
sudo apt install -y virtualbox

# Add the user to the vboxusers group
sudo usermod -aG vboxusers $(whoami)

# Download the VirtualBox Extension Pack
wget https://download.virtualbox.org/virtualbox/$(vboxmanage --version | cut -dr -f1)/Oracle_VM_VirtualBox_Extension_Pack-$(vboxmanage --version | cut -dr -f1).vbox-extpack

# Install the Extension Pack
sudo VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-$(vboxmanage --version | cut -dr -f1).vbox-extpack

# Clean up downloaded files
rm Oracle_VM_VirtualBox_Extension_Pack-$(vboxmanage --version | cut -dr -f1).vbox-extpack

# Notify the user
echo "VirtualBox installation completed. You can now launch VirtualBox from the application menu or by typing 'virtualbox' in the terminal."
