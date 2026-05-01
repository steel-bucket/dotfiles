#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

PERCENTAGE="$(pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
CHARGING="$(pmset -g batt | grep -q 'AC Power' && echo 1 || true)"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

ICON="${SB_ICON_BATT:-BAT}"

if [ "${SB_ICON_SET:-emoji}" = "nerd" ]; then
  BUCKET=$(( (PERCENTAGE + 5) / 10 * 10 ))
  if [ "$BUCKET" -gt 100 ] 2>/dev/null; then
    BUCKET=100
  fi

  ICON="󰂎"
  if [ "$CHARGING" != "" ]; then
    case "$BUCKET" in
      100) ICON="󰂅" ;;
      90) ICON="󰂋" ;;
      80) ICON="󰂊" ;;
      70) ICON="󰢞" ;;
      60) ICON="󰂉" ;;
      50) ICON="󰢝" ;;
      40) ICON="󰂈" ;;
      30) ICON="󰂇" ;;
      20) ICON="󰂆" ;;
      10) ICON="󰢜" ;;
      *) ICON="󰢟" ;;
    esac
  else
    case "$BUCKET" in
      100) ICON="󰁹" ;;
      90) ICON="󰂂" ;;
      80) ICON="󰂁" ;;
      70) ICON="󰂀" ;;
      60) ICON="󰁿" ;;
      50) ICON="󰁾" ;;
      40) ICON="󰁽" ;;
      30) ICON="󰁼" ;;
      20) ICON="󰁻" ;;
      10) ICON="󰁺" ;;
      *) ICON="󰂎" ;;
    esac
  fi
else
  if [ "$CHARGING" != "" ]; then
    ICON="${SB_ICON_BATT_CHG:-$ICON}"
  fi
fi

ICON_COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"
if [ "$CHARGING" != "" ]; then
  ICON_COLOR="${SB_COLOR_SUCCESS:-0xFF16A34A}"
else
  if [ "$PERCENTAGE" -le 20 ]; then
    ICON_COLOR="${SB_COLOR_DANGER:-0xFFDC2626}"
  elif [ "$PERCENTAGE" -le 40 ]; then
    ICON_COLOR="${SB_COLOR_WARNING:-0xFFD97706}"
  fi
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  label="${PERCENTAGE}%" \
  icon.color="$ICON_COLOR" \
  label.color="${SB_COLOR_TEXT:-0xFF111827}"
