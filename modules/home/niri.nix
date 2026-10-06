{ ... }:
{
  config.sefirah.homeModules = [
    ({ config, lib, pkgs, ... }:
    let
      # Guard for Niri-only idle commands: swayidle runs on both compositors
      # (same graphical-session.target), so lock/DPMS commands must no-op on Hyprland
      # where hypridle already owns locking. `niri msg` fails without a Niri
      # socket, making this a reliable runtime probe (no env guessing).
      niri-only = pkgs.writeShellScriptBin "niri-only" ''
        if ${pkgs.niri}/bin/niri msg outputs >/dev/null 2>&1; then
          exec "$@"
        fi
      '';

      tc = config.lib.stylix.colors;
      hx = hex: lib.toLower (lib.removePrefix "#" hex);
      homeDir = config.home.homeDirectory;
      scriptsDir = "${homeDir}/.config/hypr/scripts";
      # Cursor follows the Stylix-driven pointer theme (see nixos/stylix.nix);
      # single override point if Niri should ever diverge from it.
      cursorTheme = config.home.pointerCursor.name;
      cursorSize = toString config.home.pointerCursor.size;

      # @@PLACEHOLDER@@ substitution with an assertion so a renamed
      # anchor fails the build instead of shipping a literal "@@...@@".
      subst = placeholders: prev:
        let
          from = builtins.attrNames placeholders;
          to = builtins.attrValues placeholders;
          next = lib.replaceStrings from to prev;
        in
        assert lib.assertMsg (!lib.any (ph: lib.hasInfix ph next) from)
          "niri placeholder missing: ${next}";
        next;

      themePlaceholders = {
        "@@BASE00@@" = hx tc.base00;
        "@@BASE02@@" = hx tc.base02;
        "@@BASE08@@" = hx tc.base08;
        "@@BASE0B@@" = hx tc.base0B;
        "@@BASE0D@@" = hx tc.base0D;
      };

      pathPlaceholders = {
        "@@HOME@@" = homeDir;
        "@@SCRIPTS@@" = scriptsDir;
        "@@CURSOR_SIZE@@" = cursorSize;
        "@@CURSOR_THEME@@" = cursorTheme;
      };

      # Modular config, mirroring files/hypr/*.lua + bindings/*.lua.
      # Fragments were derived from the niri upstream default config
      # (version follows pkgs.niri); on update, diff the new default
      # against files/niri/* before rebuilding.
      # each fragment is a complete top-level node, except binds/* which
      # are lines concatenated inside a single `binds {}` (Niri forbids
      # a second binds block — a parse error).
      input = builtins.readFile ./files/niri/input.kdl;
      output = builtins.readFile ./files/niri/output.kdl;
      layout = subst themePlaceholders (builtins.readFile ./files/niri/layout.kdl);
      windows = builtins.readFile ./files/niri/windows.kdl;
      cursor = subst pathPlaceholders (builtins.readFile ./files/niri/cursor.kdl);
      autostart = subst pathPlaceholders (builtins.readFile ./files/niri/autostart.kdl);
      env = subst pathPlaceholders (builtins.readFile ./files/niri/env.kdl);
      misc = builtins.readFile ./files/niri/misc.kdl;
      overview = subst themePlaceholders (builtins.readFile ./files/niri/overview.kdl);
      bindsApps = builtins.readFile ./files/niri/binds/apps.kdl;
      bindsTiling = builtins.readFile ./files/niri/binds/tiling.kdl;
      bindsMedia = builtins.readFile ./files/niri/binds/media.kdl;
      bindsUtilities = subst pathPlaceholders (builtins.readFile ./files/niri/binds/utilities.kdl);
      bindsSystem = builtins.readFile ./files/niri/binds/system.kdl;

      binds = ''
        binds {
            Mod+Shift+Slash { show-hotkey-overlay; }

        ${bindsApps}
        ${bindsMedia}
        ${bindsTiling}
        ${bindsUtilities}
        ${bindsSystem}
        }
      '';

      fullConfig = lib.concatStringsSep "\n" [
        ''// sefirah: modular niri config — see files/niri/*.kdl + binds/*.kdl.''
        ''// Validated at build time (`niri validate` via wayland.windowManager.niri).''
        input
        output
        layout
        windows
        cursor
        autostart
        env
        misc
        overview
        binds
      ];
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

      wayland.windowManager.niri = {
        enable = true;
        # Same package programs.niri installs: no version drift, and it turns
        # on build-time `niri validate` for the generated config below.
        package = pkgs.niri;
        # UWSM owns the session (niri-uwsm session entry via programs.uwsm);
        # do not also install niri-session units from Home Manager.
        systemd.enable = false;
        # Portals are owned by programs.niri on the system side.
        portalPackage = null;
        enableDefaultConfig = false;
        # NOTE: no waybar spawn here — the waybar user service (services.nix)
        # is the single bar launcher on both compositors.
        extraConfigEarly = fullConfig;
        settings = { };
      };

      # Niri-scoped session env. UWSM sources uwsm/env-niri (XDG_CURRENT_DESKTOP=niri).
      # Niri itself reads its cursor size from the launch environment — the
      # `environment {}` block in config.kdl only feeds spawned clients.
      xdg.configFile."uwsm/env-niri".text = ''
        export XCURSOR_SIZE="${cursorSize}"
        export XCURSOR_THEME="${cursorTheme}"
      '';

      # Idle baseline mirroring hypridle (300s lock / 330s DPMS off).
      # Every command is Niri-guarded so the shared swayidle unit is a
      # harmless no-op on Hyprland (where hypridle owns idle).
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
            command = "${niri-only}/bin/niri-only ${pkgs.niri}/bin/niri msg action power-off-monitors";
            resumeCommand = "${niri-only}/bin/niri-only ${pkgs.niri}/bin/niri msg action power-on-monitors";
          }
        ];
      };
    })
  ];
}
