-- Utilities (standalone build).
-- Binds whose binary is missing are skipped with a log warning (see helper.lua).

-- notify-send ships via libnotify in home.packages, on Hyprland's exec PATH.
local notify_send = "notify-send"

-- Lock (hyprlock UI).
o.bind("SUPER + CTRL + L", "Lock system", "hyprlock")

-- Power menu via tofi dmenu (lock / suspend / reboot / power off).
o.bind("SUPER + ESCAPE", "Power menu", "/home/blackmage/.config/hypr/scripts/power-tofi.sh")

-- Activity monitor (works today: kitty + btop).
o.bind("SUPER + CTRL + T", "Activity", { tui = "btop" })

-- Zoom (native, no deps).
o.bind("SUPER + CTRL + Z", "Zoom in", function()
  local zoom = hl.get_config("cursor.zoom_factor") or 1
  hl.config({ cursor = { zoom_factor = zoom + 1 } })
end)

o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", function()
  hl.config({ cursor = { zoom_factor = 1 } })
end)

-- Screenshot / launcher (enabled automatically once
-- the binaries exist; skipped until then).
o.bind("PRINT", "Screenshot", "grim -g \"$(slurp)\" - | satty --filename -")
-- Clipboard history (needs cliphist watcher storing entries, see autostart.lua).
o.bind("SUPER + comma", "Clipboard", "cliphist list | tofi --prompt-text 'Clipboard' | cliphist decode | wl-copy")
hl.unbind("SUPER + E")
o.bind("SUPER + SHIFT + E", "File manager", "nautilus")

-- Lid switch: close lid -> lock.
o.bind("switch:on:Lid Switch", "Lock on lid close", "hyprlock", { locked = true })

-- Window transparency toggle (flips the default-opacity rule from windows.lua).
local transparent = true
o.bind("SUPER + BACKSPACE", "Toggle window transparency", function()
  transparent = not transparent
  if _G.default_opacity_rule then
    _G.default_opacity_rule:set_enabled(transparent)
  end
end)

-- Window gaps toggle.
local gaps_on = true
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", function()
  gaps_on = not gaps_on
  if gaps_on then
    hl.config({ general = { gaps_in = 5, gaps_out = 10 } })
  else
    hl.config({ general = { gaps_in = 0, gaps_out = 0 } })
  end
end)

-- Wallpaper picker (tofi over ~/Pictures/wallpapers).
o.bind("SUPER + CTRL + SPACE", "Wallpaper picker", "/home/blackmage/.config/hypr/scripts/wallpaper-tofi.sh")

-- Keybinding cheat sheet (live list from hyprctl binds, middle overlay).
-- User override: SUPER + ALT + K (was SUPER + ALT + SPACE).
hl.unbind("SUPER + ALT + SPACE")
o.bind("SUPER + ALT + K", "Show key bindings",
  o.launch("kitty --class keybinds -- /home/blackmage/.config/hypr/scripts/keybinds.sh"))

-- Bar toggle (SIGUSR1 flips waybar visibility; starts the HM user service
-- if it is not running).
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + ALT + SPACE", "Toggle top bar", "pkill -USR1 waybar || systemctl --user start waybar.service")
o.bind("SUPER + SHIFT + SPACE", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))

-- Mako notification dismiss.
-- User override: SUPER + comma stays Clipboard (below), so dismiss-last moves to SUPER + ALT + comma.
hl.unbind("SUPER + comma")
o.bind("SUPER + ALT + comma", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + comma", "Dismiss all notifications", "makoctl dismiss --all")

-- Calculator.
o.bind("SUPER + CTRL + Q", "Calculator", "qalculate-gtk")

-- Nightlight toggle (hyprsunset has no toggle flag: kill it or start it).
-- if/else (not &&/|| chains): a failed notify-send must never relaunch the daemon,
-- and stdout is detached so exec never hangs the caller.
o.bind("SUPER + CTRL + N", "Toggle nightlight",
  "sh -c 'if pkill -x hyprsunset; then " .. notify_send .. " \"Nightlight\" \"Off\"; else uwsm-app -- hyprsunset --temperature 3500 >/dev/null 2>&1 & " .. notify_send .. " \"Nightlight\" \"On\"; fi'")

-- Idle toggle (hypridle runs as an HM user service).
o.bind("SUPER + CTRL + I", "Toggle locking on idle",
  "sh -c 'if systemctl --user is-active --quiet hypridle.service; then systemctl --user stop hypridle.service && " .. notify_send .. " \"Idle lock\" \"Off\"; else systemctl --user start hypridle.service && " .. notify_send .. " \"Idle lock\" \"On\"; fi'")
