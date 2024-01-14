#!/bin/bash

# Check for available updates
updates=$(apt list --upgradable 2>/dev/null | grep -c ^)

# Check if updates are available
if [ "$updates" -gt 1 ]; then
  echo "%{F#ff0000}%{F-}"
else
  echo ""
fi

# The value needs to be greater then 1 to work as it
# counts the number of lines returned. When no updates
# are available, it returns 'Listing...Done' which is
# one line.