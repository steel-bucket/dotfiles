#!/usr/bin/env bash
set -euo pipefail

wifi="$(
  {
    nmcli -t -f active,ssid dev wifi 2>/dev/null |
      awk -F: '$1 == "yes" {print $2; exit}'
  } || true
)"
wifi="${wifi:-offline}"

volume="$(
  {
    pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null |
      awk 'NR == 1 {print $5; exit}'
  } || true
)"
volume="${volume:-n/a}"

battery="$(
  {
    upower -e 2>/dev/null |
      while read -r device; do
        case "$device" in
          *BAT*) upower -i "$device"; break ;;
        esac
      done |
      awk '/percentage:/ {print $2; exit}'
  } || true
)"
battery="${battery:-AC}"

printf 'wifi %s | vol %s | bat %s | %s\n' \
  "$wifi" "$volume" "$battery" "$(date '+%a %d %b %H:%M')"
