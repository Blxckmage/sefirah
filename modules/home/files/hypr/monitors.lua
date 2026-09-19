-----------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- Single laptop panel confirmed via `hyprctl monitors` (BOE 1920x1080@60).
-- Add extra hl.monitor blocks when you dock external displays.

hl.monitor({
  output   = "eDP-1",
  mode     = "1920x1080@60",
  position = "auto",
  scale    = "1.2",
})

-- Fallback for any other / future outputs.
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = "auto",
})

-- XWayland apps (Steam) render at native pixels instead of being
-- resampled to the fractional compositor scale: crisp and smaller
-- rather than choppy and big.
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})
