#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

# The volume_change event supplies a $INFO variable with the current volume %
# (SketchyBar can still "force" this script, so we also support a fallback).

VOLUME="${INFO:-}"
if [ "$VOLUME" = "" ] || [ "$SENDER" != "volume_change" ]; then
  VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 0)"
fi

MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)"

ICON="${SB_ICON_VOL_HIGH:-Vol}"
ICON_COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"
if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ] 2>/dev/null; then
  ICON="${SB_ICON_VOL_MUTE:-Mut}"
  ICON_COLOR="${SB_COLOR_DANGER:-0xFFDC2626}"
elif [ "$VOLUME" -ge 66 ] 2>/dev/null; then
  ICON="${SB_ICON_VOL_HIGH:-Vol}"
elif [ "$VOLUME" -ge 33 ] 2>/dev/null; then
  ICON="${SB_ICON_VOL_MID:-Vol}"
else
  ICON="${SB_ICON_VOL_LOW:-Vol}"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$ICON_COLOR" \
  label="${VOLUME}%" \
  label.color="${SB_COLOR_TEXT:-0xFF111827}"
