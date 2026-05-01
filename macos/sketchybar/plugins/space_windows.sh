#!/usr/bin/env bash

set -euo pipefail

source "$CONFIG_DIR/theme.sh" 2>/dev/null || true

SPACE_IDS=({0..30} {A..Z})
FOCUSED_CACHE_FILE="${TMPDIR:-/tmp}/sketchybar_aerospace_focused_workspace"
WORKSPACE_META_FORMAT="%{workspace}%{tab}%{monitor-appkit-nsscreen-screens-id}%{tab}%{workspace-is-visible}%{tab}%{workspace-is-focused}"

valid_workspace() {
  [[ "${1:-}" =~ ^[A-Za-z0-9]+$ ]]
}

aerospace_available() {
  aerospace list-workspaces --focused >/dev/null 2>&1
}

get_focused_workspace() {
  local ws="${FOCUSED_WORKSPACE:-}"

  if valid_workspace "$ws"; then
    printf '%s\n' "$ws"
    return 0
  fi

  if ws="$(aerospace list-workspaces --focused --format "%{workspace}" 2>/dev/null)"; then
    ws="${ws%%$'\n'*}"
  else
    ws=""
  fi

  if valid_workspace "$ws"; then
    printf '%s\n' "$ws"
    return 0
  fi

  return 1
}

get_visible_workspaces() {
  aerospace list-workspaces --monitor all --visible --format "%{workspace}" 2>/dev/null || true
}

workspace_is_visible() {
  local ws="$1"
  local visible_nl="$2"
  case "$visible_nl" in
    *$'\n'"$ws"$'\n'*) return 0 ;;
    *) return 1 ;;
  esac
}

set_space_focused_style() {
  local ws="$1"
  valid_workspace "$ws" || return 0

  sketchybar --animate tanh 14 --set "space.$ws" \
    background.color="${SB_COLOR_ACCENT_BG:-0x550EA5E9}" \
    background.border_color="${SB_COLOR_ACCENT:-0xFF0EA5E9}" \
    background.border_width=2 \
    icon.color="${SB_COLOR_TEXT:-0xFF0F172A}" \
    label.color="${SB_COLOR_TEXT:-0xFF0F172A}"
}

set_space_unfocused_style() {
  local ws="$1"
  valid_workspace "$ws" || return 0

  sketchybar --animate tanh 14 --set "space.$ws" \
    background.color="${SB_COLOR_SURFACE:-0xE6FFFFFF}" \
    background.border_color="${SB_COLOR_BORDER:-0x260E7490}" \
    background.border_width=1 \
    icon.color="${SB_COLOR_TEXT:-0xFF0F172A}" \
    label.color="${SB_COLOR_SUBTEXT:-0xFF334155}"
}

read_cached_focused() {
  [ -f "$FOCUSED_CACHE_FILE" ] || return 1
  head -n 1 "$FOCUSED_CACHE_FILE" 2>/dev/null || true
}

write_cached_focused() {
  printf '%s\n' "$1" >"$FOCUSED_CACHE_FILE" 2>/dev/null || true
}

icon_strip_for_apps() {
  local apps_nl="$1"
  local icon_strip=""

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    icon_strip+=" $("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app")"
  done <<<"$apps_nl"

  printf '%s\n' "${icon_strip# }"
}

set_space_item() {
  local ws="$1"
  local drawing="$2"
  local icons="${3:-}"
  local display_id="${4:-}"

  local display_prop="display=active"
  if [[ "$display_id" =~ ^[0-9]+$ ]]; then
    display_prop="display=$display_id"
  fi

  if [ "$drawing" = "on" ] && [ -n "$icons" ]; then
    sketchybar --set "space.$ws" "$display_prop" drawing=on label=" $icons"
  else
    sketchybar --set "space.$ws" "$display_prop" drawing="$drawing" label=""
  fi
}

get_workspace_meta_lines() {
  aerospace list-workspaces --all --format "$WORKSPACE_META_FORMAT" 2>/dev/null || true
}

get_workspace_display_id() {
  local ws="$1"
  local meta_lines="$2"

  if [ -z "$meta_lines" ]; then
    return 1
  fi

  local display_id
  display_id="$(printf '%s\n' "$meta_lines" | awk -F'\t' -v ws="$ws" '$1==ws {print $2; exit}')"
  [[ "$display_id" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$display_id"
}

workspace_is_visible_meta() {
  local ws="$1"
  local meta_lines="$2"

  [ -n "$meta_lines" ] || return 1
  local visible
  visible="$(printf '%s\n' "$meta_lines" | awk -F'\t' -v ws="$ws" '$1==ws {print $3; exit}')"
  [ "$visible" = "true" ]
}

refresh_workspace() {
  local ws="$1"
  local focused_ws="$2"
  local meta_lines="$3"

  valid_workspace "$ws" || return 0

  local display_id=""
  display_id="$(get_workspace_display_id "$ws" "$meta_lines" 2>/dev/null || true)"

  local apps
  if ! apps="$(aerospace list-windows --workspace "$ws" --format "%{app-name}" 2>/dev/null)"; then
    return 0
  fi
  apps="$(printf '%s\n' "$apps" | sed '/^$/d' | LC_ALL=C sort -u)"

  local icons=""
  if [ -n "$apps" ]; then
    icons="$(icon_strip_for_apps "$apps")"
  fi

  local drawing="off"
  if [ "$ws" = "$focused_ws" ] || [ -n "$icons" ] || workspace_is_visible_meta "$ws" "$meta_lines"; then
    drawing="on"
  fi

  set_space_item "$ws" "$drawing" "$icons" "$display_id"
}

refresh_all() {
  local focused_ws
  if ! focused_ws="$(get_focused_workspace)"; then
    return 0
  fi

  local meta_lines
  meta_lines="$(get_workspace_meta_lines)"

  local window_lines
  if window_lines="$(aerospace list-windows --all --format "%{workspace}%{tab}%{app-name}" 2>/dev/null)"; then
    :
  else
    window_lines=""
  fi

  local icon_map=""
  if [ -n "$window_lines" ]; then
    local sorted
    sorted="$(printf '%s\n' "$window_lines" | sed '/^$/d' | LC_ALL=C sort -t $'\t' -k1,1 -k2,2 | LC_ALL=C uniq)"

    local current_ws=""
    local current_icons=""
    while IFS=$'\t' read -r ws app; do
      valid_workspace "$ws" || continue
      [ -z "$app" ] && continue

      if [ "$ws" != "$current_ws" ]; then
        if [ -n "$current_ws" ]; then
          icon_map+="$current_ws"$'\t'"${current_icons# }"$'\n'
        fi
        current_ws="$ws"
        current_icons=""
      fi

      current_icons+=" $("$CONFIG_DIR/plugins/icon_map_fn.sh" "$app")"
    done <<<"$sorted"

    if [ -n "$current_ws" ]; then
      icon_map+="$current_ws"$'\t'"${current_icons# }"$'\n'
    fi
  fi

  for ws in "${SPACE_IDS[@]}"; do
    local icons=""
    if [ -n "$icon_map" ]; then
      icons="$(printf '%s' "$icon_map" | awk -v ws="$ws" -F'\t' '$1==ws {print $2; exit}')"
    fi

    local display_id=""
    display_id="$(get_workspace_display_id "$ws" "$meta_lines" 2>/dev/null || true)"

    local drawing="off"
    if [ "$ws" = "$focused_ws" ] || [ -n "$icons" ] || workspace_is_visible_meta "$ws" "$meta_lines"; then
      drawing="on"
    fi

    set_space_item "$ws" "$drawing" "$icons" "$display_id"
  done
}

main() {
  aerospace_available || exit 0

  local focused_ws
  focused_ws="$(get_focused_workspace || true)"
  [ -n "$focused_ws" ] || exit 0

  local meta_lines
  meta_lines="$(get_workspace_meta_lines)"

  local previous_ws=""
  if valid_workspace "${PREV_WORKSPACE:-}"; then
    previous_ws="$PREV_WORKSPACE"
  else
    previous_ws="$(read_cached_focused || true)"
  fi

  if valid_workspace "$previous_ws" && [ "$previous_ws" != "$focused_ws" ]; then
    set_space_unfocused_style "$previous_ws"
  fi
  set_space_focused_style "$focused_ws"
  write_cached_focused "$focused_ws"

  case "${SENDER:-}" in
    aerospace_workspace_change)
      if valid_workspace "${PREV_WORKSPACE:-}"; then
        refresh_workspace "$PREV_WORKSPACE" "$focused_ws" "$meta_lines"
      fi
      refresh_workspace "$focused_ws" "$focused_ws" "$meta_lines"
      ;;

    aerospace_focus_change)
      refresh_workspace "$focused_ws" "$focused_ws" "$meta_lines"
      ;;

    *)
      refresh_all
      ;;
  esac
}

main "$@"
