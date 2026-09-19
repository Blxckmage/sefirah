-- App launching (converted from classic bindings.lua, Omarchy pre-Quattro scheme).
-- All commands use installed binaries; missing ones are skipped (see helper.lua).
--
-- Conflict resolutions vs the Quattro scheme (user overrides win):
-- * SUPER + W unbound (close = SUPER + Q / SUPER + SHIFT + Q).
-- * SUPER + S = togglesplit; scratchpad stays on SUPER + grave (SUPER + ALT + S / SHIFT + grave move).
-- * SUPER + SHIFT + SPACE = floating (bar toggle moved to SUPER + ALT + SPACE).
-- * Maximized = SUPER + SHIFT + F (not SUPER + ALT + F).
-- * Workspace move on SUPER + SHIFT = silent (no separate ALT triple).
-- * SUPER + V stays unbound; SHIFT + F11 / ALT + F11 were no-ops.
-- * Keybinding viewer = SUPER + ALT + K (see utilities.lua).
-- * Clipboard = SUPER + comma via cliphist + tofi (walker not installed).

-- Terminal.
o.bind("SUPER + Return", "Terminal", o.launch("kitty"))

-- Browser.
o.bind("SUPER + SHIFT + W", "Browser", o.launch("brave"))

-- Launcher (tofi drun, fullscreen theme; drun-launch=true actually runs the app).
o.bind("SUPER + D", "Launch apps", "tofi-drun --drun-launch=true")

-- Close active window (SUPER + Q also works, see tilings.lua).
o.bind("SUPER + SHIFT + Q", "Close active window", hl.dsp.window.close())

-- Keybinding viewer lives in utilities.lua as SUPER + ALT + K.
