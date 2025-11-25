#!/bin/bash

# Configures Thunar to bind the 'Navigate Back' action (previous directory) to the XF86Back key by modifying ~/.config/Thunar/accels.scm.
# Creates the config file if missing, appends the keybinding if absent, and restarts Thunar if running.

ACCELS_FILE="$HOME/.config/Thunar/accels.scm"
BACK_LINE='(gtk_accel_path "<Actions>/ThunarStandardView/back" "XF86Back")'

# Ensure accels.scm exists
mkdir -p "$(dirname "$ACCELS_FILE")"
touch "$ACCELS_FILE"

# Check if the line exists and is uncommented
if ! grep -Fx "$BACK_LINE" "$ACCELS_FILE" > /dev/null; then
    # Append the line if it’s missing or commented
    echo "$BACK_LINE" >> "$ACCELS_FILE"
    # Only restart Thunar if it’s running
    if pgrep -x thunar > /dev/null; then
        killall thunar 2>/dev/null
        nohup thunar >/dev/null 2>&1 &
    fi
fi
