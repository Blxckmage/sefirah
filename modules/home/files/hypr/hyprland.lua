-- Hyprland Lua entrypoint (thin loader).
-- Adapted from Omarchy Quattro: Omarchy bindings win, no omarchy-* deps.
-- https://wiki.hypr.land/Configuring/Start/

require("helper")
require("envs")
require("autostart")
require("monitors")
require("looknfeel")
require("input")
require("windows")

require("bindings.tilings")
require("bindings.apps")
require("bindings.media")
require("bindings.utilities")

-- Set programs that you use (must exist in PATH; see NixOS packages).
-- local terminal = "kitty"
-- local browser = "brave"
