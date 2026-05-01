#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

# Sum of user + sys CPU, rounded to nearest integer.
CPU_PCT="$(top -l 1 -n 0 | awk '/CPU usage/ {printf \"%d\", ($3 + $5) + 0.5}')"
CPU_PCT="${CPU_PCT:-0}"

COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"
if [ "$CPU_PCT" -ge 80 ]; then
  COLOR="${SB_COLOR_DANGER:-0xFFDC2626}"
elif [ "$CPU_PCT" -ge 60 ]; then
  COLOR="${SB_COLOR_WARNING:-0xFFD97706}"
fi

sketchybar --set "$NAME" \
  icon="CPU" \
  icon.font="${SB_FONT_FAMILY:-SF Pro}:Bold:${SB_FONT_SIZE:-11.0}" \
  icon.color="$COLOR" \
  label="${CPU_PCT}%" \
  label.color="${SB_COLOR_TEXT:-0xFF111827}"
