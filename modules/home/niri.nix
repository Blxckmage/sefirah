{ ... }:
{
  config.sefirah.homeModules = [
    ({ config, lib, pkgs, ... }:
    let
      # Guard for Niri-only idle commands: swayidle runs on both compositors
      # (same graphical-session.target), so lock commands must no-op on Hyprland
      # where hypridle already owns locking. `niri msg` fails without a Niri
      # socket, making this a reliable runtime probe (no env guessing).
      niri-only = pkgs.writeShellScriptBin "niri-only" ''
        if ${pkgs.niri}/bin/niri msg outputs >/dev/null 2>&1; then
          exec "$@"
        fi
      '';
    in
    {
      home.packages = with pkgs; [
        niri-only
        swaylock
        swayidle
        swaybg
        gammastep # nightlight on Niri (hyprsunset needs Hyprland IPC)
        # xwayland-satellite arrives via wayland.windowManager.niri below
        # (default), so XWayland apps like Steam keep working on Niri.
      ];

      # Theme include (Stylix -> Niri layout), merged over the vendored
      # defaults via include-positionality. Mirrors hypr/theme/colors.lua:
      # active gradient base0D->base0B @45deg, inactive base02.
      xdg.configFile."niri/sefirah-theme.kdl".text =
        let
          tc = config.lib.stylix.colors.withHashtag;
          hx = hex: lib.toLower (lib.removePrefix "#" hex);
        in
        ''
          // Generated from Stylix palette. Do not hand-edit.
          layout {
              // Hyprland gaps_in 5 / gaps_out 10.
              gaps 5
              struts {
                  left 10
                  right 10
                  top 10
                  bottom 10
              }
              // Single-frame look like Hyprland: border on, focus ring off.
              focus-ring {
                  off
              }
              border {
                  // Explicit on: in an included file, bare border {} is a no-op.
                  on
                  width 2
                  active-gradient from="#${hx tc.base0D}" to="#${hx tc.base0B}" angle=45
                  inactive-color "#${hx tc.base02}aa"
                  urgent-color "#${hx tc.base08}"
              }
          }
          overview {
              backdrop-color "#${hx tc.base00}"
          }
        '';

      wayland.windowManager.niri = {
        enable = true;
        # Same package programs.niri installs: no version drift, and it turns
        # on build-time `niri validate` for the generated config below.
        package = pkgs.niri;
        # UWSM owns the session (niri-uwsm SDDM entry); do not also install
        # niri-session units from Home Manager.
        systemd.enable = false;
        # Portals are owned by programs.niri on the system side.
        portalPackage = null;
        # Baseline = upstream default config, vendored verbatim in
        # files/niri/default-config.kdl (minus its `spawn-at-startup "waybar"`.
        # which would duplicate the systemd bar service). Included first ...
        enableDefaultConfig = false;
        extraConfigEarly = builtins.readFile ./files/niri/default-config.kdl + ''
          // sefirah: Stylix theme include (merges over vendored layout above).
          include "/home/blackmage/.config/niri/sefirah-theme.kdl"
        '';
        settings = { };
        # ... then only session essentials appended after it. Binds merge
        # per-key with the defaults, so Mod+Return/Mod+D below only add to
        # (or override) those keys. Full bind/layout migration comes later.
        # NOTE: no waybar spawn here — the waybar user service (services.nix)
        # is the single bar launcher on both compositors.
        extraConfig = ''
          // --- sefirah Niri baseline (Hyprland config untouched) ---

          // Session essentials (mirrors hypr/autostart.lua).
          spawn-at-startup "swaybg" "-i" "/home/blackmage/Pictures/wallpaper.jpg" "-m" "fill"
          spawn-at-startup "sh" "-c" "wl-paste --type text --watch cliphist store"
          spawn-at-startup "sh" "-c" "wl-paste --type image --watch cliphist store"

          // Cursor / toolkit env (mirrors hypr/envs.lua).
          environment {
              XCURSOR_THEME "Bibata-Modern-Classic"
              XCURSOR_SIZE "16"
              HYPRCURSOR_SIZE "16"
              GDK_SCALE "1"
              QT_QPA_PLATFORMTHEME "kvantum"
              QT_STYLE_OVERRIDE "kvantum"
              QT_PLUGIN_PATH "/etc/profiles/per-user/blackmage/lib/qt-6/plugins:/etc/profiles/per-user/blackmage/lib/qt-5.15.19/plugins"
          }

          // (Launch binds live in the vendored binds block above: Mod+Return
          // kitty, Mod+D tofi-drun. A second binds {} node is a parse error.)
        '';
      };

      # Idle baseline mirroring hypridle (300s lock / 330s DPMS off).
      # Runs on both compositors but every command is Niri-safe: lock commands
      # are guarded by niri-only, and `niri msg` fails harmlessly on Hyprland.
      services.swayidle = {
        enable = true;
        events = {
          before-sleep = "${niri-only}/bin/niri-only ${pkgs.swaylock}/bin/swaylock";
        };
        timeouts = [
          {
            timeout = 300;
            command = "${niri-only}/bin/niri-only ${pkgs.swaylock}/bin/swaylock";
          }
          {
            timeout = 330;
            command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
            resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
          }
        ];
      };
    })
  ];
}
