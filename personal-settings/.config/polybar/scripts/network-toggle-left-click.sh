#!/bin/bash

# Get current status 
status=$(nmcli networking connectivity)

if [ "$status" = "full" ]; then
  current="Connected"
else
  current="Disconnected"
fi

# Show menu
selection=$(echo -e "$current\nToggle Connection" | rofi -dmenu -p "Network Options")

# Take action
if [ "$selection" = "Toggle Connection" ]; then

  if [ "$status" = "full" ]; then
    nmcli networking off
  else
    nmcli networking on
  fi

  # Notify
  if [ "$status" = "full" ]; then
    notify-send "Network disconnected"
  else
    notify-send "Network connected"
  fi

fi
