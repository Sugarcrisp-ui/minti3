#!/bin/bash

options="On\nOff"

choice=$(echo -e "$options" | rofi -dmenu -p "Toggle Network")

if [ "$choice" = "On" ]; then
  nmcli networking on
elif [ "$choice" = "Off" ]; then 
  nmcli networking off
fi
