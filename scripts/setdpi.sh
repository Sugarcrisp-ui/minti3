#!/usr/bin/env bash
# ~/.bin-personal/set-dpi.sh
# Sets DPI for desktop (brett-ms-7d82) or laptop (brett-K501UX)

set -euo pipefail

LOG_FILE="$HOME/log-files/dpi/set-dpi.log"
XRESOURCES_TEMP="$HOME/.Xresources-dpi"
HOSTNAME=$(hostname)

mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date): Starting DPI setup for $HOSTNAME" >> "$LOG_FILE"

case "$HOSTNAME" in
    "brett-ms-7d82")
        DPI=120
        ;;
    "brett-K501UX")
        DPI=90
        ;;
    *)
        DPI=100
        echo "$(date): Unknown hostname: $HOSTNAME, using default DPI: $DPI" >> "$LOG_FILE"
        ;;
esac

echo "Xft.dpi: $DPI" > "$XRESOURCES_TEMP"
if xrdb -merge "$XRESOURCES_TEMP" >> "$LOG_FILE" 2>&1; then
    echo "$(date): Set DPI to $DPI for $HOSTNAME" >> "$LOG_FILE"
else
    echo "$(date): Failed to set DPI to $DPI for $HOSTNAME" >> "$LOG_FILE"
fi
rm -f "$XRESOURCES_TEMP"
