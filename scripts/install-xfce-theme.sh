#!/bin/bash

# Set environment for D-Bus and XFCE compatibility
export DISPLAY=:0
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Install Arc theme
sudo apt-get install -y arc-theme

# Apply Arc-Darker theme
xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker"
xfconf-query -c xfwm4 -p /general/theme -s "Arc-Darker"
