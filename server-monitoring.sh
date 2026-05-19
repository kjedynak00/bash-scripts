#!/bin/bash
# Script to monitor disk CPU and RAM usage and send alert if usage exceeds threshold
# 14.11.2025 - Drive monitoring added
# 25.11.2025 - Cpu monitoring added
# 25.11.2025 - RAM monitoring added
# 24.04.2025 - Machine uptime and Network traffic (RX/TX bytes per active interface) added
# 19.05.2025 - Load Average and Avaliable updates checked added

#List of monitored drives
PARTITION=("/" "/boot")
WEBHOOK_URL="https://example.com/webhook" # Replace with your webhook URL

for PART in "${PARTITION[@]}"; do
    USAGE=$(df -h "$PART" | awk 'NR==2 {gsub("%","",$5); print $5}')
    if [ $USAGE -gt 60 ] ; then
        MESSAGE="⚠️Warning: Disk usage on partition $PART is at ${USAGE}%"
        curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
        "$WEBHOOK_URL"
    fi
done

#CPU usage monitoring
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
if (( $(echo "$CPU_USAGE > 70" | bc -l) )); then
    MESSAGE="⚠️Warning: CPU usage is at ${CPU_USAGE}%"
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
     "$WEBHOOK_URL"
fi

#RAM usage monitoring
RAM_USAGE=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2 * 100}')
if (( $(echo "$RAM_USAGE > 70" | bc -l) )); then
    MESSAGE="⚠️Warning: RAM usage is at ${RAM_USAGE}%"
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \
    "$WEBHOOK_URL"
fi

#Machine uptime
UPTIME=$(uptime -p)
MESSAGE="🕐 Uptime: ${UPTIME}"
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \ 
    "$WEBHOOK_URL"

#Network traffic (RX/TX bytes per active interface)
IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
RX=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
TX=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)
MESSAGE="🌐 $IFACE RX: $(numfmt --to=iec $RX) TX: $(numfmt --to=iec $TX)"
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" \ 
    "$WEBHOOK_URL"

#Load average
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
MESSAGE="📊 Load average:$LOAD"
curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" "$WEBHOOK_URL"

# Check available updates
UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)

if [ "$UPDATES" -gt 0 ]; then
    MESSAGE="📦 Available package updates: $UPDATES"
    curl -X POST -H 'Content-type: application/json' --data "{\"content\":\"$MESSAGE\"}" "$WEBHOOK_URL"
fi
