#!/bin/bash

# Check network status
if nmcli -t -f STATE g | grep -q "connected"; then
    echo "%{F#00FF00}%{F-}"  # Green icon for connected
else
    echo "%{F#FF0000}%{F-}"  # Red icon for disconnected
fi
