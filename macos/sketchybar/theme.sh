#!/usr/bin/env bash

# SketchyBar theme + sizing tokens
# Goal: compact (50% smaller) but still readable, with a cohesive palette.

# ----------------------------
# Sizing
# ----------------------------
export SB_BAR_HEIGHT="${SB_BAR_HEIGHT:-20}"
export SB_BAR_MARGIN="${SB_BAR_MARGIN:-8}"
export SB_BAR_RADIUS="${SB_BAR_RADIUS:-10}"

export SB_ITEM_HEIGHT="${SB_ITEM_HEIGHT:-16}"
export SB_ITEM_RADIUS="${SB_ITEM_RADIUS:-8}"

# ----------------------------
# Typography
# ----------------------------
export SB_FONT_FAMILY="${SB_FONT_FAMILY:-SF Pro}"
export SB_FONT_STYLE="${SB_FONT_STYLE:-Semibold}"
export SB_FONT_SIZE="${SB_FONT_SIZE:-11.0}"

export SB_ICON_FONT_FAMILY="${SB_ICON_FONT_FAMILY:-Hack Nerd Font}"
export SB_ICON_FONT_STYLE="${SB_ICON_FONT_STYLE:-Bold}"
export SB_ICON_FONT_SIZE="${SB_ICON_FONT_SIZE:-12.0}"

export SB_APP_ICON_FONT="${SB_APP_ICON_FONT:-sketchybar-app-font}"
export SB_APP_ICON_FONT_SIZE="${SB_APP_ICON_FONT_SIZE:-12.0}"

# ----------------------------
# Icons
# ----------------------------
# `emoji` is the most reliable default (no extra font installs).
# If you have a Nerd Font installed, you can set `SB_ICON_SET=nerd` for
# monochrome, font-tintable icons.
export SB_ICON_SET="${SB_ICON_SET:-emoji}"

if [ "$SB_ICON_SET" = "nerd" ]; then
  export SB_STATUS_ICON_FONT="$SB_ICON_FONT_FAMILY:$SB_ICON_FONT_STYLE:$SB_ICON_FONT_SIZE"

  export SB_ICON_DATE=""
  export SB_ICON_CLOCK="󱑓"
  export SB_ICON_WIFI_ON="󰖩"
  export SB_ICON_WIFI_OFF="󰖪"
  export SB_ICON_VOL_MUTE="󰕿"
  export SB_ICON_VOL_LOW="󰕽"
  export SB_ICON_VOL_MID="󰖀"
  export SB_ICON_VOL_HIGH="󰕾"
  export SB_ICON_BATT="󰁹"
  export SB_ICON_BATT_CHG="󰂅"
else
  # Keep a normal, reliable font here and let CoreText fallback render emoji.
  export SB_STATUS_ICON_FONT="$SB_FONT_FAMILY:$SB_FONT_STYLE:$SB_ICON_FONT_SIZE"

  export SB_ICON_DATE="📅"
  export SB_ICON_CLOCK="🕒"
  export SB_ICON_WIFI_ON="📶"
  export SB_ICON_WIFI_OFF="⛔"
  export SB_ICON_VOL_MUTE="🔇"
  export SB_ICON_VOL_LOW="🔈"
  export SB_ICON_VOL_MID="🔉"
  export SB_ICON_VOL_HIGH="🔊"
  export SB_ICON_BATT="🔋"
  export SB_ICON_BATT_CHG="🔌"
fi

# ----------------------------
# Colors (ARGB: 0xAARRGGBB)
# ----------------------------
# Switch palettes by setting `SB_THEME=light|dark` before launching SketchyBar.
SB_THEME="${SB_THEME:-light}"

if [ "$SB_THEME" = "dark" ]; then
  # Catppuccin Mocha-inspired
  export SB_COLOR_BG="${SB_COLOR_BG:-0xAA1E1E2E}"
  export SB_COLOR_SURFACE="${SB_COLOR_SURFACE:-0x66313244}"
  export SB_COLOR_SURFACE_STRONG="${SB_COLOR_SURFACE_STRONG:-0x99313244}"
  export SB_COLOR_BORDER="${SB_COLOR_BORDER:-0x33CDD6F4}"

  export SB_COLOR_TEXT="${SB_COLOR_TEXT:-0xFFCDD6F4}"
  export SB_COLOR_SUBTEXT="${SB_COLOR_SUBTEXT:-0xB3A6ADC8}"

  export SB_COLOR_ACCENT="${SB_COLOR_ACCENT:-0xFFB4BEFE}"
  export SB_COLOR_ACCENT_BG="${SB_COLOR_ACCENT_BG:-0x55B4BEFE}"

  export SB_COLOR_WARNING="${SB_COLOR_WARNING:-0xFFF9E2AF}"
  export SB_COLOR_DANGER="${SB_COLOR_DANGER:-0xFFF38BA8}"
  export SB_COLOR_SUCCESS="${SB_COLOR_SUCCESS:-0xFFA6E3A1}"
else
  # Sky Blue (light) — frosted + airy
  export SB_COLOR_BG="${SB_COLOR_BG:-0xCCF0F9FF}"                 # sky-50
  export SB_COLOR_SURFACE="${SB_COLOR_SURFACE:-0xE6FFFFFF}"       # pill surface
  export SB_COLOR_SURFACE_STRONG="${SB_COLOR_SURFACE_STRONG:-0xFFFFFFFF}"
  export SB_COLOR_BORDER="${SB_COLOR_BORDER:-0x260E7490}"         # blue-gray border

  export SB_COLOR_TEXT="${SB_COLOR_TEXT:-0xFF0F172A}"             # slate-900
  export SB_COLOR_SUBTEXT="${SB_COLOR_SUBTEXT:-0xFF334155}"       # slate-700

  export SB_COLOR_ACCENT="${SB_COLOR_ACCENT:-0xFF0EA5E9}"         # sky-500
  export SB_COLOR_ACCENT_BG="${SB_COLOR_ACCENT_BG:-0x330EA5E9}"   # accent wash

  export SB_COLOR_WARNING="${SB_COLOR_WARNING:-0xFFD97706}"
  export SB_COLOR_DANGER="${SB_COLOR_DANGER:-0xFFDC2626}"
  export SB_COLOR_SUCCESS="${SB_COLOR_SUCCESS:-0xFF16A34A}"
fi
