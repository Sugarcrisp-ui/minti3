#!/bin/bash

selection=$(echo -e "Network Settings\nConnection Info\nRestart Network\nNetwork Diagnostics" | rofi -dmenu -p "Network Options")

case "$selection" in
  "Network Settings")
    nm-connection-editor
    ;;
  "Connection Info")
    xfce4-terminal -e 'bash -c "nmcli connection show; read"'
    ;;
  "Restart Network")
    nmcli networking off
    sleep 2
    nmcli networking on
    ;;
  "Network Diagnostics")
    xfce4-terminal -e 'bash -c "nmcli general status; read"'
    ;;
esac
