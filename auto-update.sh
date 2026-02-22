#!/bin/bash
# Version 1.0 Auto-update script to pull latest upgrades and log the update time
# Verion 1.1 - Added webhook notification with list of updated packages
# Version 1.2 - Added check for available updates before patching and logging accordingly
LOGFILE="/mnt/usb-drv/1tb/log.txt"
WEBHOOK_URL="https://example.com/webhook" # Replace with your webhook URL
HOSTNAME=$(hostname)
NEW_PACKAGES=$(apt-get -s upgrade | awk '/^Inst / {print $2}')
PKG_LIST=$(echo "$NEW_PACKAGES" | tr '\n' ', ')
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")


patching(){
    sudo apt-get update -y;
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y;
};

if [ -z "$NEW_PACKAGES" ]; then
    echo "$TIMESTAMP - No new packages to update." >> "$LOGFILE"
    MESSAGE="$TIMESTAMP - No updates available on $HOSTNAME."
        curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
        "$WEBHOOK_URL"

else
    patching;
    echo "$TIMESTAMP - System updated successfully" >> "$LOGFILE"
    MESSAGE="$TIMESTAMP - System updated successfully on $HOSTNAME. New/updated packages: $PKG_LIST"
        curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
        "$WEBHOOK_URL"
fi

