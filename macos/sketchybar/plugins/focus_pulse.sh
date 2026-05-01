#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

WS="${FOCUSED_WORKSPACE:-${AEROSPACE_FOCUSED_WORKSPACE:-}}"
if [ "$WS" = "" ]; then
  exit 0
fi

WS_ITEM="space.$WS"

# Subtle "pulse" (border width) so window cycling feels responsive without
# being distracting.
sketchybar --animate tanh 10 --set front_app \
  background.border_color="${SB_COLOR_ACCENT:-0xFF2563EB}" \
  background.border_width=2

sketchybar --animate tanh 10 --set "$WS_ITEM" \
  background.border_width=3

sleep 0.10

sketchybar --animate tanh 20 --set front_app \
  background.border_color="${SB_COLOR_BORDER:-0x260B0D0E}" \
  background.border_width=1

# The focused workspace style uses border_width=2 (see aerospace.sh).
sketchybar --animate tanh 20 --set "$WS_ITEM" \
  background.border_width=2

