#!/usr/bin/env bash
# setdpi.sh – 2025-12-12 FINAL: T14 support + current DPI 140

set -euo pipefail

LOG_FILE="$HOME/log-files/dpi/set-dpi.log"
XRESOURCES_TEMP="$HOME/.Xresources-dpi"
HOSTNAME=$(hostname)

mkdir -p "$(dirname "$LOG_FILE")"
echo "$(date): Starting DPI setup for $HOSTNAME" >> "$LOG_FILE"

case "$HOSTNAME" in
    "brett-ms-7d82")          # Desktop
        DPI=120
        ;;
    "brett-K501UX")           # Old laptop
        DPI=90
        ;;
    *"thinkpad-t14"* | *"t14"*)   # New T14 (any variant)
        DPI=140
        echo "$(date): T14 detected – using DPI 140" >> "$LOG_FILE"
        ;;
    *)
        DPI=140
        echo "$(date): Unknown host $HOSTNAME – defaulting to DPI 140 (T14 standard)" >> "$LOG_FILE"
        ;;
esac

echo "Xft.dpi: $DPI" > "$XRESOURCES_TEMP"

if xrdb -merge "$XRESOURCES_TEMP" >> "$LOG_FILE" 2>&1; then
    echo "$(date): Successfully set DPI to $DPI for $HOSTNAME" >> "$LOG_FILE"
else
    echo "$(date): Failed to set DPI to $DPI for $HOSTNAME" >> "$LOG_FILE"
    exit 1
fi

rm -f "$XRESOURCES_TEMP"
echo "DPI set to $DPI – done"
