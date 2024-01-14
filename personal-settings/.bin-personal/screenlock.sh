#!/bin/bash

options="lock\nsuspend\nlogout\nrestart\nshutdown"

chosen=$(echo -e "$options" | rofi -dmenu -p "Select an action:")

case $chosen in
  lock)
    i3lock-fancy
    ;;
  suspend)
    systemctl suspend &
    sleep 1  # Add a short delay
    i3lock-fancy
    ;;
  logout)
    i3-msg exit
    ;;
  restart)
    systemctl reboot
    ;;
  shutdown)
    systemctl poweroff
    ;;
  *)
    echo "Invalid option"
    ;;
esac
