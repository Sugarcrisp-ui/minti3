#!/bin/bash

# Terminate already running bar instances 
killall -q polybar

# Restart nm-tray
pkill -USR1 -x nm-tray

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Launch Polybar on the primary monitor
MONITOR=VGA-1 polybar --reload mainbar-i3-desktop -c ~/.config/polybar/config.ini &
