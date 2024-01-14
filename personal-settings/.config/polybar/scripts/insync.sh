#!/bin/bash

# Check if InSync is running
if pgrep -x "insync" > /dev/null; then
   echo "%{F#5be610} Insync"
else
   echo "%{F#FF0000} Insync"
fi
