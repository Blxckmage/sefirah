{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }:
    let
      wallpaper = "${../theme/wallpapers/epoch-umber-lock.png}";

      sefirah-lock = pkgs.writeShellScriptBin "sefirah-lock" ''
        cfg="$HOME/.config/sefirah/current/hypr/hyprlock.conf"
        if [ ! -s "$cfg" ]; then
          SEFIRAH_WALLPAPER="${wallpaper}" ${pkgs.sefirah}/bin/sefirah transmute >/dev/null 2>&1 || true
        fi
        if [ -s "$cfg" ]; then
          exec ${pkgs.hyprlock}/bin/hyprlock --config "$cfg" --immediate-render --no-fade-in "$@"
        fi
        exec ${pkgs.hyprlock}/bin/hyprlock --immediate-render --no-fade-in "$@"
      '';
    in
    {
      home.packages = [ sefirah-lock ];

      home.sessionVariables.SEFIRAH_WALLPAPER = wallpaper;
      xdg.configFile."uwsm/env.d/sefirah".text = ''
        export SEFIRAH_WALLPAPER="${wallpaper}"
      '';

      # Generate hyprlock config at startup
      xdg.configFile."autostart/sefirah-transmute.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Sefirah Transmute
        Exec=${pkgs.sefirah}/bin/sefirah transmute
        X-GNOME-Autostart-enabled=true
      '';
    })
  ];
}
