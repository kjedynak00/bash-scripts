#!/bin/bash
# Version 1.0 Ping to 8.8.8.8 and log status changes
# Version 1.1 added state file and emotes for better log reading
LOGFILE="/mnt/usb-drv/1tb/log.txt"
STATEFILE="/mnt/usb-drv/1tb/state.txt"

# Load previous state if exists
if [ -f "$STATEFILE" ]; then
    STATUS=$(cat "$STATEFILE")
else
    STATUS="UP"
fi

while true; do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    if ! ping -c 1 -W 5 8.8.8.8 &> /dev/null; then
        if [ "$STATUS" != "DOWN" ]; then
            echo "$TIMESTAMP - 🌐 INTERNET DOWN" >> "$LOGFILE"
            STATUS="DOWN"
        fi
    else
        if [ "$STATUS" != "UP" ]; then
            echo "$TIMESTAMP - ✅ INTERNET BACK UP" >> "$LOGFILE"
            STATUS="UP"
        fi
    fi
    echo "$STATUS" > "$STATEFILE"
    sleep 15
done
