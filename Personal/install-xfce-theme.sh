#!/bin/bash

# Install Arc-Darker theme
sudo apt install arc-theme -y

# Set Arc-Darker as GTK theme
xfconf-query -c xsettings -p /Net/ThemeName -s Arc-Darker

# Verify theme setting
xfconf-query -c xsettings -p /Net/ThemeName