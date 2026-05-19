#!/bin/bash
# Version 0.1 Added message and dates etc.

WEBHOOK_URL="https://example.com/webhook"
HOSTNAME=$(hostname)
DATE=$(date +"%Y-%m-%d %H:%M:%S")

MESSAGE="📊 Daily Homelab Report - $DATE 🖥️ Host: $HOSTNAME"

curl -X POST \
  -H "Content-Type: application/json" \
  --data "$(jq -n --arg content "$MESSAGE" '{content: $content}')" \
  "$WEBHOOK_URL"
