#!/bin/bash

while true; do
    # Get the current time
    current_time=$(date +"%H:%M:%S")

    # Generate the lock screen text with different fonts and sizes
    convert -size 1920x1080 xc:black -font "DejaVu-Sans-Mono-Bold" -pointsize 50 -fill white -gravity southwest -annotate +50+120 "$current_time" /tmp/locktext.png

    # Sleep for 1 second (adjust as needed)
    sleep 1
done
