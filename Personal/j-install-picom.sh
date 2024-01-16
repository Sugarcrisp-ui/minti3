#!/bin/bash

# Set noninteractive mode
export DEBIAN_FRONTEND=noninteractive

# Install picom without prompts
sudo apt install -y picom

# Create picom configuration directory
mkdir -p ~/.config/picom

# Create a basic picom configuration file
cat <<EOF > ~/.config/picom/picom.conf
# Basic picom configuration

# Use the xrender backend
backend = "xrender";

# Enable shadows
shadow = true;
no-dnd-shadow = true;
no-dock-shadow = true;

# Enable transparency
clear-shadow = true;

# Fading windows
fading = true;
fade-delta = 5;
fade-in-step = 0.03;
fade-out-step = 0.03;
fade-exclude = ["class_g = 'Conky'"];

# Other settings
detect-rounded-corners = true;
detect-client-opacity = true;

EOF

# Print a message
echo "Picom installed and basic configuration created. You can customize ~/.config/picom/picom.conf further as needed."
