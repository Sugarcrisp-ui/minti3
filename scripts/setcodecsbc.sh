#!/bin/bash
# set-codec-sbc.sh – 2025 final: force SBC on your Bluetooth devices
# Runs on login → perfect audio every time

set -euo pipefail

LOG="$HOME/log-files/bluetooth/set-codec-sbc.log"
mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG"; }

# Your devices (add/remove as needed)
declare -A DEVICES=(
    ["C0:C2:0F:86:2A:7A"]="AirPods Black"
    ["41:42:84:E3:BC:26"]="Buds Green"
    ["41:42:EB:13:29:6A"]="Buds Red"
)

log "Checking Bluetooth devices for SBC codec..."

for mac in "${!DEVICES[@]}"; do
    card="bluez_card.$(echo "$mac" | tr ':' '_')"

    # Wait up to 5 seconds for the card to appear
    for i in {1..5}; do
        if pactl list cards | grep -q "$card"; then
            current=$(pactl send-message /card/"$card"/bluez get-codec 2>/dev/null | tr -d '"')
            log "Found ${DEVICES[$mac]} ($mac) → current codec: ${current:-none}"

            if [[ "$current" != "sbc" ]]; then
                log "Switching ${DEVICES[$mac]} to SBC"
                pactl send-message /card/"$card"/bluez switch-codec '"sbc"' >> "$LOG" 2>&1 || log "Failed to switch"
            else
                log "${DEVICES[$mac]} already on SBC"
            fi
            break
        fi
        sleep 1
    done
done

log "SBC check complete"
