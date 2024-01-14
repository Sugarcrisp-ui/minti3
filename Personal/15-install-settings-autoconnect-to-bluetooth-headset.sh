#!/bin/bash

set -e

# The set command is used to determine action if an error is encountered.
# (-e) will stop and exit, and (+e) will continue with the script.
set -e

##################################################################################################################
# Settings for a Bluetooth headset.
# After reboot, switch off and on your device to get connected automatically and to the right channel.

# Update main.conf to enable automatic device connection.
echo "Fix 1"
echo "#################"
FIND="#AutoEnable=false"
REPLACE="AutoEnable=true"
sudo sed -i "s/$FIND/$REPLACE/g" /etc/bluetooth/main.conf

if grep --quiet AutoEnable=true /etc/bluetooth/main.conf; then
  echo "Autoenable=true is already added"
fi

# Add module-switch-on-connect to default.pa to switch to the Bluetooth device on connect.
echo "Fix 2"
echo "#################"
if ! grep --quiet "module-switch-on-connect" /etc/pulse/default.pa; then
    echo "load-module module-switch-on-connect" | sudo tee -a /etc/pulse/default.pa > /dev/null
fi

# Create a backup file for bluetooth-clear.conf before modifying it.
echo "Fix 3"
echo "#################"
[ -f /etc/modprobe.d/bluetooth-clear.conf ] && echo "Bluetooth-clear already created" || echo 'options ath9k btcoex_enable = 1' | sudo tee /etc/modprobe.d/bluetooth-clear.conf

echo "################################################################"
echo "#########   reboot to let the settings kick in  ################"
echo "################################################################"
