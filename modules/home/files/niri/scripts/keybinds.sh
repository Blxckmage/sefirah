#!/usr/bin/env bash
# Live keybind cheat sheet (never goes stale).
# Parses the binds {} block of the live niri config.kdl.
set -u

awk '
/^[[:space:]]*binds \{$/ { in_binds = 1; next }
in_binds && /^[[:space:]]*\}/ { in_binds = 0; next }
in_binds && /\{/ && $0 !~ /^[[:space:]]*\/\// {
  line = $0
  key = $1
  title = ""
  if (match(line, /hotkey-overlay-title="[^"]*"/)) {
    title = substr(line, RSTART + 22, RLENGTH - 23)
  }
  action = line
  sub(/^[^{]*\{[[:space:]]*/, "", action)
  sub(/[[:space:]]*\}[[:space:]]*$/, "", action)
  printf "%-28s %-32s %s\n", key, title, action
}' "$HOME/.config/niri/config.kdl" | less -S
