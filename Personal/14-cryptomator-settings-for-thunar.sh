#!/bin/bash

# The set command is used to determine action if error 
# is encountered.  (-e) will stop and exit (+e) will 
# continue with the script.
set -e

# This script sets thunar as the default program to use as 
# the file manager

xdg-mime default thunar.desktop inode/directory

# Print a message indicating that the settings were installed
echo "Thunar is now the default file manager for Cryptomator"

