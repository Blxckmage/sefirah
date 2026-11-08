#!/usr/bin/env bash
# Power menu via tofi dmenu (fullscreen theme).
# Esc / empty choice does nothing.
#
# NOTE: actions use exec (not &) so they survive as the main process.
set -u

choice=$(printf 'Lock\nRelaunch\nReboot\nPower off' | tofi --prompt-text "Power: ")

case "$choice" in
  Lock) exec sefirah-lock ;;
  Relaunch) exec uwsm stop ;;
  Reboot) exec systemctl reboot ;;
  "Power off") exec systemctl poweroff ;;
  *) ;;
esac
