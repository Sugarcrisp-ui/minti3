#!/bin/bash

USER=$(whoami)

# Install Arc theme
sudo apt-get install -y arc-theme

# Apply Arc-Darker theme in the user's graphical session
echo "Applying Arc-Darker theme..."
if sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$USER")/bus xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Darker" 2>/dev/null; then
    echo "Successfully set xsettings theme to Arc-Darker."
else
    echo "Warning: Failed to set xsettings theme. XFCE session may not be active."
fi
if sudo -u "$USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u "$USER")/bus xfconf-query -c xfwm4 -p /general/theme -s "Arc-Darker" 2>/dev/null; then
    echo "Successfully set xfwm4 theme to Arc-Darker."
else
    echo "Warning: Failed to set xfwm4 theme. XFCE session may not be active."
fi
