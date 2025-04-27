#!/bin/bash

# Ensure D-Bus environment for xfconf-query
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus

# Install Arc-Darker theme
sudo apt install arc-theme -y

# Set Arc-Darker as GTK theme
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus xfconf-query -c xsettings -p /Net/ThemeName -s Arc-Darker

# Verify theme setting
DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u brett)/bus xfconf-query -c xsettings -p /Net/ThemeName
