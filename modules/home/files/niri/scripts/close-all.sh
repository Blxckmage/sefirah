#!/bin/sh
# Close all windows on the active workspace.
set -eu

ws=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused) | .id')
niri msg -j windows | jq -r --argjson ws "$ws" \
  '.[] | select(.workspace_id == $ws) | .id' |
  while IFS= read -r id; do
    niri msg action close-window --id "$id" >/dev/null 2>&1
  done
