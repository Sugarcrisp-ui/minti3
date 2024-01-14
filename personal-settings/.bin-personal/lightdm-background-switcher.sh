#!/bin/bash

# Ask for the new image file location
echo "Enter the full path of the new image file:"
read new_image

# Define the configuration file
conf_file="/etc/lightdm/lightdm-gtk-greeter.conf.d/99_linuxmint.conf"

# Check if there is a commented out background line
if grep -q "^#background=" $conf_file; then
    # If there is a commented out line and a second background line, replace the second background line
    sudo sed -i "/^background=/c\background=$new_image" $conf_file
else
    # If there is only one background line, comment it out and add a new background line
    sudo sed -i "/^background=/s/^/#/" $conf_file
    echo "background=$new_image" | sudo tee -a $conf_file
fi

echo "Background updated. Please reboot your system for the changes to take effect."

# The lightdm config file is located /etc/lightdm/lightdm-gtk-greeter.conf.d/99_linuxmint.conf

# This script first asks for the full path of the new image file. It then checks the configuration 
# file for a commented out background line. If such a line exists, it replaces the second background 
# line with the new image location. If there is only one background line, it comments it out and 
# adds a new background line with the new image location.

# Remember to run this script with sudo privileges as it modifies a system configuration file. Always b
# e careful when running scripts as sudo.