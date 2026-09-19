-- Volume, brightness, and media controls (standalone, native tools).
-- Missing binaries are skipped with a log warning (see helper.lua).
-- NixOS: add brightnessctl + playerctl to environment.systemPackages.

-- Volume (PipeWire).
o.bind("XF86AudioRaiseVolume", "Volume up", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
  { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
  { locked = true, repeating = true })
o.bind("XF86AudioMute", "Mute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
o.bind("XF86AudioMicMute", "Mute microphone", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
o.bind("ALT + XF86AudioRaiseVolume", "Volume up precise", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+",
  { locked = true, repeating = true })
o.bind("ALT + XF86AudioLowerVolume", "Volume down precise", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-",
  { locked = true, repeating = true })

-- Display brightness.
o.bind("XF86MonBrightnessUp", "Brightness up", "brightnessctl -e4 -n2 set 5%+",
  { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "brightnessctl -e4 -n2 set 5%-",
  { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessUp", "Brightness maximum", "brightnessctl -e4 -n2 set 100%",
  { locked = true, repeating = true })
o.bind("SHIFT + XF86MonBrightnessDown", "Brightness minimum", "brightnessctl -e4 -n2 set 1%",
  { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessUp", "Brightness up precise", "brightnessctl -e4 -n2 set +1%",
  { locked = true, repeating = true })
o.bind("ALT + XF86MonBrightnessDown", "Brightness down precise", "brightnessctl -e4 -n2 set 1%-",
  { locked = true, repeating = true })

-- Keyboard backlight (no-op without the device; skipped if brightnessctl missing).
o.bind("XF86KbdBrightnessUp", "Keyboard brightness up", "brightnessctl --device='*kbd*' set +10%",
  { locked = true, repeating = true })
o.bind("XF86KbdBrightnessDown", "Keyboard brightness down", "brightnessctl --device='*kbd*' set 10%-",
  { locked = true, repeating = true })

-- Touchpad (native hyprctl keywords).
o.bind("XF86TouchpadToggle", "Toggle touchpad", "hyprctl keyword input:touchpad:enabled $(hyprctl getoption input:touchpad:enabled -j | grep -q '\"int\": 1' && echo false || echo true)", { locked = true })
o.bind("XF86TouchpadOn", "Enable touchpad", "hyprctl keyword input:touchpad:enabled true", { locked = true })
o.bind("XF86TouchpadOff", "Disable touchpad", "hyprctl keyword input:touchpad:enabled false", { locked = true })

-- Media controls (needs playerctl).
o.bind("XF86AudioNext", "Next track", "playerctl next", { locked = true })
o.bind("XF86AudioPause", "Play/Pause", "playerctl play-pause", { locked = true })
o.bind("XF86AudioPlay", "Play/Pause", "playerctl play-pause", { locked = true })
o.bind("XF86AudioPrev", "Previous track", "playerctl previous", { locked = true })
o.bind("XF86Eject", "Eject media", "eject", { locked = true })
