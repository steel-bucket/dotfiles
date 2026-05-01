#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

WIFI_DEVICE="$(
  networksetup -listallhardwareports 2>/dev/null | awk '
    $0 ~ /^Hardware Port: (Wi-Fi|AirPort)$/ { found=1; next }
    found && $0 ~ /^Device: / { print $2; exit }
  '
)"

if [ "$WIFI_DEVICE" = "" ]; then
  WIFI_DEVICE="en0"
fi

SSID="$(networksetup -getairportnetwork "$WIFI_DEVICE" 2>/dev/null | sed -n 's/^Current Wi-Fi Network: //p')"

ICON="${SB_ICON_WIFI_OFF:-WiFi}"
ICON_COLOR="${SB_COLOR_DANGER:-0xFFDC2626}"
LABEL="Off"
LABEL_COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"

if [ "$SSID" != "" ]; then
  ICON="${SB_ICON_WIFI_ON:-WiFi}"
  ICON_COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"
  LABEL="$SSID"
  LABEL_COLOR="${SB_COLOR_TEXT:-0xFF111827}"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="$LABEL" \
  icon.color="$ICON_COLOR" \
  label.color="$LABEL_COLOR"
