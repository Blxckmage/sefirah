-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window(".*", { suppress_event = "maximize" })

-- Tag all windows for default opacity (apps can override with -default-opacity tag).
o.window(".*", { tag = "+default-opacity" })

-- Fix some dragging issues with XWayland.
o.window(
  {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  { no_focus = true }
)

-- Keybind cheat sheet: middle overlay (smaller than the screen).
o.window("keybinds", { float = true, center = true, size = "880 560" })

-- Waybar popups: foot TUIs and pavucontrol float centered, never split.
o.window("waybar%-btop", { float = true, center = true, size = "1000 620" })
o.window("waybar%-wifi", { float = true, center = true, size = "900 600" })
o.window("[Pp]avucontrol", { float = true, center = true, size = "900 620" })

-- App-specific tweaks live here (keep file loadable without omarchy).
-- e.g. o.window("firefox", { opacity = "1.0 1.0" }) to opt out of default opacity.

-- Apply default opacity after apps have had a chance to opt out.
-- Handle is global so the transparency toggle bind can flip it.
_G.default_opacity_rule = o.window({ tag = "default-opacity" }, { opacity = "0.985 0.96" })
