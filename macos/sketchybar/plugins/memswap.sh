#!/usr/bin/env bash

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

DEFCOLOR="${SB_COLOR_SUBTEXT:-0x44FFFFFF}"
ALERTCOLOR="${SB_COLOR_DANGER:-0xAAFF0000}"
TOTALSWAP="$(sysctl vm.swapusage | awk '{print $4}')"

clr=""
if [ "$TOTALSWAP" != "0.00M" ]; then
    clr="$ALERTCOLOR"
else
    clr="$DEFCOLOR"
fi

sketchybar --set "$NAME" label="$TOTALSWAP" icon.color="$clr" label.color="$clr"
