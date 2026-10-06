#!/usr/bin/env bash
# Battery profile picker (power-profiles-daemon) via tofi.
# Click the Waybar battery module to choose balanced / performance /
# power-saver (whatever the hardware offers). Esc / empty choice does nothing.
set -u

if ! command -v powerprofilesctl >/dev/null 2>&1; then
  notify-send "Power profiles" "power-profiles-daemon missing — rebuild first"
  exit 1
fi

current=$(powerprofilesctl get 2>/dev/null || echo "?")
menu=$(powerprofilesctl list 2>/dev/null | awk '
  {
    line = $0
    active = (line ~ /^\*/)
    sub(/^ *\*? */, "", line)
    if (line ~ /^[a-z-]+:/) {
      sub(/:.*$/, "", line)
      if (active) print "● " line; else print "○ " line
    }
  }')
[ -z "$menu" ] && { notify-send "Power profiles" "No profiles available"; exit 1; }

choice=$(printf '%s\n' "$menu" | tofi --prompt-text "Profile: ") || exit 0
[ -z "$choice" ] && exit 0
profile=$(printf '%s' "$choice" | sed 's/^[●○] //')
[ "$profile" = "$current" ] && exit 0

if powerprofilesctl set "$profile" 2>/dev/null; then
  notify-send "Power profile" "$profile"
else
  notify-send "Power profile" "Failed to set $profile"
fi
