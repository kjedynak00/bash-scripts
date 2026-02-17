#!/bin/bash
# Version 1.0 Auto-update script to pull latest upgrades and log the update time
# Verion 1.1 - Added webhook notification with list of updated packages
LOGFILE="/mnt/usb-drv/1tb/log.txt"
WEBHOOK_URL="https://example.com/webhook" # Replace with your webhook URL
HOSTNAME=$(hostname)
NEW_PACKAGES=$(apt-get -s upgrade | awk '/^Inst / {print $2}')
PKG_LIST=$(echo "$NEW_PACKAGES" | tr '\n' ', ')


patching(){
    sudo apt-get update -y;
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y;
};

patching;
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "$TIMESTAMP - System updated successfully" >> "$LOGFILE"
 MESSAGE="$TIMESTAMP - System updated successfully on $HOSTNAME. New/updated packages: $PKG_LIST"
        curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
        "$WEBHOOK_URL"