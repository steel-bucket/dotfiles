#!/usr/bin/env bash

set -euo pipefail

sketchybar --reload >/dev/null 2>&1 || true

if command -v aerospace >/dev/null 2>&1; then
  aerospace reload-config >/dev/null 2>&1 || true
fi

echo "Reloaded SketchyBar (and AeroSpace if running)."
