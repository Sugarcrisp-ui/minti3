#!/bin/bash

# Run the expressvpn status command and capture the output
vpn_status=$(expressvpn status)

# Extract the connected location from the output
connected_location=$(echo "$vpn_status" | awk -F 'Connected to ' '{print $2}' | sed -E -e 's/ - [0-9]+$//')

# Check if the VPN is connected
if [ -n "$connected_location" ]; then
    # Display the VPN status (green when connected) and the location with a hyphen
    echo "%{F#5be610} VPN%{U#5be610} - $connected_location"
else
    # Display "VPN" in red when disconnected
    echo "%{F#FF0000} VPN%{U#FF0000}"
fi
