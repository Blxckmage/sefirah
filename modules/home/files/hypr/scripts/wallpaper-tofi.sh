#!/usr/bin/env bash
# Wallpaper picker via tofi (SUPER + CTRL + SPACE).
# Lists ~/Pictures/wallpapers and applies the pick immediately by swapping
# the ~/Pictures/wallpaper.jpg symlink that hyprpaper.conf points at —
# so the choice survives reboots with no config edits.
# Esc / empty choice does nothing.
set -u

WALL_DIR="$HOME/Pictures/wallpapers"
LINK="$HOME/Pictures/wallpaper.jpg"

files=$(find "$WALL_DIR" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
  -printf '%f\n' 2>/dev/null | sort)
if [ -z "$files" ]; then
  notify-send "Wallpapers" "Drop images into ~/Pictures/wallpapers first"
  exit 1
fi

choice=$(printf 'Random\n%s\n' "$files" | tofi --prompt-text "Wallpaper: ") || exit 0
[ -z "$choice" ] && exit 0

if [ "$choice" = "Random" ]; then
  pick=$(printf '%s\n' "$files" | shuf -n 1)
else
  pick="$choice"
fi
src="$WALL_DIR/$pick"
[ -f "$src" ] || { notify-send "Wallpapers" "Not found: $pick"; exit 1; }

ln -sf "$src" "$LINK"
# Hyprland >= 0.55: only `wallpaper MONITOR,PATH[,FIT]` exists
# (preload/unload were removed; preloading is automatic).
hyprctl hyprpaper wallpaper "eDP-1,$LINK" >/dev/null 2>&1 \
  || hyprctl hyprpaper wallpaper ",$LINK" >/dev/null 2>&1
notify-send "Wallpaper" "$pick"
