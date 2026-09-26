#!/usr/bin/env bash
# Power menu via tofi dmenu (fullscreen theme).
# Esc / empty choice does nothing.
#
# NOTE: actions use exec (not &) so they survive as the main process:
# Hyprland runs binds in a scope that can reap backgrounded children,
# which silently killed `hyprlock &` and the logout.
set -u

# Locker follows the running compositor (shared by Hyprland and Niri bars).
if niri msg outputs >/dev/null 2>&1; then
  locker=swaylock
else
  locker=hyprlock
fi

choice=$(printf 'Lock\nSuspend\nRelaunch\nReboot\nPower off' | tofi --prompt-text "Power: ")

case "$choice" in
  Lock) exec "$locker" ;;
  Suspend) exec systemctl suspend ;;
  Relaunch) exec uwsm stop ;;
  Reboot) exec systemctl reboot ;;
  "Power off") exec systemctl poweroff ;;
  *) ;;
esac
