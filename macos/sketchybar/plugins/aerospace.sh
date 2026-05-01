#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

if [ "$1" = "${FOCUSED_WORKSPACE:-}" ]; then
  sketchybar --animate tanh 14 --set "$NAME" \
    background.color="${SB_COLOR_ACCENT_BG:-0x55B4BEFE}" \
    background.border_color="${SB_COLOR_ACCENT:-0xFFB4BEFE}" \
    background.border_width=2 \
    icon.color="${SB_COLOR_TEXT:-0xffffffff}" \
    label.color="${SB_COLOR_TEXT:-0xffffffff}"
else
  sketchybar --animate tanh 14 --set "$NAME" \
    background.color="${SB_COLOR_SURFACE:-0x66313244}" \
    background.border_color="${SB_COLOR_BORDER:-0x33ffffff}" \
    background.border_width=1 \
    icon.color="${SB_COLOR_TEXT:-0xffffffff}" \
    label.color="${SB_COLOR_SUBTEXT:-0xb3ffffff}"
fi
