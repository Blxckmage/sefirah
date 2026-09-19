#!/usr/bin/env bash
# Live keybind cheat sheet from `hyprctl binds` (never goes stale).
set -u

hyprctl binds | awk '
function mods(m,   s) {
  s = ""
  if (m >= 64) { s = s "SUPER + "; m -= 64 }
  if (m >= 32) { s = s "MOD3 + "; m -= 32 }
  if (m >= 16) { s = s "MOD2 + "; m -= 16 }
  if (m >= 8)  { s = s "ALT + "; m -= 8 }
  if (m >= 4)  { s = s "CTRL + "; m -= 4 }
  if (m >= 2)  { s = s "CAPS + "; m -= 2 }
  if (m >= 1)  { s = s "SHIFT + "; m -= 1 }
  return s
}
function show() {
  if (desc != "") {
    # code: binds already carry their mods inside key: (e.g. "SUPER + SHIFT + code:10").
    if (key ~ /\+/) { k = key }
    else { k = mods(mod) (key != "" ? key : "code:" code) }
    printf "%-30s  %s\n", k, desc
  }
}
/^bindd?$/ { show(); mod=""; key=""; code=""; desc=""; next }
/^\tmodmask:/ { mod = $2; next }
/^\tkey:/ { key = $2; for (i = 3; i <= NF; i++) key = key " " $i; next }
/^\tkeycode:/ { code = $2; next }
/^\tdescription:/ { sub(/^\tdescription: /, ""); desc = $0; next }
END { show() }
' | less -S
