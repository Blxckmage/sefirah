-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("sh -c 'systemctl --user start hyprpaper.service && sleep 2 && hyprpaper-random'")
end)

-- hyprpaper needs Wayland present, so it is started here (not by its
-- HM unit, whose start condition fires too early) followed by one random pick.
