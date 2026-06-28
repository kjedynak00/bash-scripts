#!/bin/bash
# Version 1.0 Auto-update script to pull latest upgrades and log the update time
# Version 1.1 - Added webhook notification with list of updated packages
# Version 1.2 - Added check for available updates before patching and logging accordingly
# Version 1.3 - Added error handling for apt and curl failures
# Version 1.4 - Added hostname to log and notification messages
LOGFILE="/mnt/NAS/home-lab/logs/updates.txt"
WEBHOOK_URL="EXAMPLE_WEBHOOK_URL"  # Replace with your actual Discord webhook URL
HOSTNAME=$(hostname)

notify(){
    local LEVEL="$1"
    local MESSAGE="$2"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "$TIMESTAMP - [$LEVEL] $MESSAGE <$HOSTNAME>" >> "$LOGFILE" 2>/dev/null || echo "Warning: failed to write to $LOGFILE"
    curl -s -X POST -H 'Content-type: application/json' \
        --data "$(jq -nc --arg msg "$TIMESTAMP - $MESSAGE" '{"content": $msg}')" \
        "$WEBHOOK_URL" 2>/dev/null || echo "Warning: failed to send Discord notification"
}

patching(){
    apt-get update -y 2>/dev/null || return 1
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 2>/dev/null || return 2
}
NEW_PACKAGES=$(apt-get -s upgrade 2>/dev/null | awk '/^Inst / {print $2}')

if [ -z "$NEW_PACKAGES" ]; then
    notify "INFO" "No updates available on **$HOSTNAME**"
else
    patching
    EXIT_CODE=$?
    PKG_LIST=$(echo "$NEW_PACKAGES" | tr '\n' ', ')

    if [ "$EXIT_CODE" -eq 0 ]; then
        notify "OK" "System updated successfully on **$HOSTNAME**. New/updated packages: $PKG_LIST"
    elif [ "$EXIT_CODE" -eq 1 ]; then
        notify "FAIL" "apt-get update failed on **$HOSTNAME**. Packages pending: $PKG_LIST"
    elif [ "$EXIT_CODE" -eq 2 ]; then
        notify "FAIL" "apt-get upgrade failed on **$HOSTNAME**. Packages pending: $PKG_LIST"
    else
        notify "FAIL" "Update failed with unknown error on **$HOSTNAME**. Packages pending: $PKG_LIST"
    fi
fi