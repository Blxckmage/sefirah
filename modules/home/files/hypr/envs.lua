-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "16")
hl.env("HYPRCURSOR_SIZE", "16")
hl.env("GDK_SCALE", "1")

-- Qt theming (Kvantum): the display-manager session does not propagate
-- HM's session variables into the compositor, so apps spawned from binds
-- and tofi would fall back to Fusion. Export here so Hyprland's children
-- (and their children) resolve the Kvantum style plugin.
hl.env("QT_QPA_PLATFORMTHEME", "kvantum")
hl.env("QT_STYLE_OVERRIDE", "kvantum")
hl.env("QT_PLUGIN_PATH",
  "/etc/profiles/per-user/blackmage/lib/qt-6/plugins:/etc/profiles/per-user/blackmage/lib/qt-5.15.19/plugins")
