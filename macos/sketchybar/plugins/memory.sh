#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

PAGESIZE="$(sysctl -n hw.pagesize 2>/dev/null)"
TOTAL_BYTES="$(sysctl -n hw.memsize 2>/dev/null)"

if [ -z "$PAGESIZE" ] || [ -z "$TOTAL_BYTES" ]; then
  exit 0
fi

read -r USED_GB USED_PCT <<EOF
$(vm_stat | awk -v pagesize="$PAGESIZE" -v total="$TOTAL_BYTES" '
  function num(x) { gsub("\\.","", x); return x + 0 }
  /Pages active/ { active = num($NF) }
  /Pages wired down/ { wired = num($NF) }
  /Pages occupied by compressor/ { comp = num($NF) }
  END {
    used = (active + wired + comp) * pagesize
    used_gb = used / 1024 / 1024 / 1024
    pct = (used / total) * 100
    printf "%.1f %d", used_gb, int(pct + 0.5)
  }')
EOF

USED_GB="${USED_GB:-0.0}"
USED_PCT="${USED_PCT:-0}"

COLOR="${SB_COLOR_SUBTEXT:-0xFF4B5563}"
if [ "$USED_PCT" -ge 85 ]; then
  COLOR="${SB_COLOR_DANGER:-0xFFDC2626}"
elif [ "$USED_PCT" -ge 70 ]; then
  COLOR="${SB_COLOR_WARNING:-0xFFD97706}"
fi

sketchybar --set "$NAME" \
  icon="RAM" \
  icon.font="${SB_FONT_FAMILY:-SF Pro}:Bold:${SB_FONT_SIZE:-11.0}" \
  icon.color="$COLOR" \
  label="${USED_GB}G" \
  label.color="${SB_COLOR_TEXT:-0xFF111827}"
