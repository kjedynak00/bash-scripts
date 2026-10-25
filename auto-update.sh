#!/bin/bash
# Version 1.0 Auto-update script to pull latest upgrades and log the update time
# Version 1.1 - Added webhook notification with list of updated packages
# Version 1.2 - Added check for available updates before patching and logging accordingly
# Version 1.3 - Added error handling for apt and curl failures
# Version 1.4 - Added hostname to log and notification messages
# Version 1.5 - Added jq fallback, reboot-required status, and clearer package update summary
# Version 1.6 - Improved update checks, added stricter error handling, and better webhook payload handling

LOGFILE="/mnt/NAS/home-lab/logs/updates.txt"
WEBHOOK_URL="EXAMPLE_WEBHOOK_URL"  # Replace with your actual Discord webhook URL
HOSTNAME="$(hostname)"
REBOOT_REQUIRED="no"

mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || {
    echo "Error: failed to create log directory for $LOGFILE" >&2
    exit 1
}
touch "$LOGFILE" 2>/dev/null || {
    echo "Error: failed to create $LOGFILE" >&2
    exit 1
}

if [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED="yes"
fi

log_event() {
    local LEVEL="$1"
    local MESSAGE="$2"
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    echo "$TIMESTAMP - [$LEVEL] $MESSAGE <$HOSTNAME>" >> "$LOGFILE" 2>/dev/null || {
        echo "Warning: failed to write to $LOGFILE" >&2
        return 1
    }

    if [ -n "$WEBHOOK_URL" ] && [ "$WEBHOOK_URL" != "EXAMPLE_WEBHOOK_URL" ]; then
        local JSON_PAYLOAD
        if command -v jq >/dev/null 2>&1; then
            JSON_PAYLOAD=$(jq -n --arg content "$TIMESTAMP - $MESSAGE" '{content:$content}')
        else
            JSON_PAYLOAD=$(printf '%s' "$TIMESTAMP - $MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g')
            JSON_PAYLOAD="{\"content\":\"$JSON_PAYLOAD\"}"
        fi
        curl -fsS -X POST \
            -H "Content-Type: application/json" \
            --data "$JSON_PAYLOAD" \
            "$WEBHOOK_URL" >/dev/null 2>&1 || echo "Warning: failed to send Discord notification" >> "$LOGFILE" 2>/dev/null || true
    fi
}

apt-get update -y 2>/dev/null
if [ $? -ne 0 ]; then
    log_event "FAIL" "apt-get update failed on **$HOSTNAME**. Packages pending: unknown | Updated: 0 | Failed: 1 | Reboot required: $REBOOT_REQUIRED"
    exit 1
fi

SIMULATION=$(apt-get -s upgrade 2>/dev/null)
SIMULATION_STATUS=$?
if [ "$SIMULATION_STATUS" -ne 0 ]; then
    log_event "FAIL" "Could not check for package updates on **$HOSTNAME**. Packages pending: unknown | Updated: 0 | Failed: 1 | Reboot required: $REBOOT_REQUIRED"
    exit "$SIMULATION_STATUS"
fi

NEW_PACKAGES=$(printf '%s\n' "$SIMULATION" | awk '/^Inst / {print $2}')
PENDING_COUNT=0
if [ -n "$NEW_PACKAGES" ]; then
    PENDING_COUNT=$(printf '%s\n' "$NEW_PACKAGES" | sed '/^$/d' | wc -l | tr -d ' ')
fi

if [ -z "$NEW_PACKAGES" ]; then
    log_event "INFO" "No updates available on **$HOSTNAME**. Packages pending: $PENDING_COUNT | Updated: 0 | Failed: 0 | Reboot required: $REBOOT_REQUIRED"
    exit 0
fi

DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 2>/dev/null
EXIT_CODE=$?
PKG_LIST=$(printf '%s\n' "$NEW_PACKAGES" | tr '\n' ', ' | sed 's/,$//')
if [ -f /var/run/reboot-required ]; then
    REBOOT_REQUIRED="yes"
else
    REBOOT_REQUIRED="no"
fi

if [ "$EXIT_CODE" -eq 0 ]; then
    log_event "OK" "System update completed on **$HOSTNAME**. Packages pending: $PENDING_COUNT | Upgrade: completed | Failed: 0 | Reboot required: $REBOOT_REQUIRED. Packages: $PKG_LIST"
else
    log_event "FAIL" "apt-get upgrade failed on **$HOSTNAME**. Packages pending: $PENDING_COUNT | Upgrade: failed | Failed: 1 | Reboot required: $REBOOT_REQUIRED. Packages: $PKG_LIST"
fi

exit "$EXIT_CODE"