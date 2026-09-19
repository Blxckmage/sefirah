#!/bin/sh
# Close all windows on the active workspace.
# Lua-era replacement for the removed `closeall` dispatcher (Hyprland >= 0.55):
# queries clients and closes each via hl.dsp.window.close().
set -eu

ws=$(hyprctl activeworkspace -j | jq -r '.id')
hyprctl clients -j | jq -r --argjson ws "$ws" \
  '.[] | select(.workspace.id == $ws) | .address' |
  while IFS= read -r addr; do
    hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null 2>&1
  done
