{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }:
    let
      sefirah = pkgs.writeScriptBin "sefirah" ''
        #!${pkgs.python3}/bin/python3
        ${builtins.replaceStrings
          [ "@@LOCK_WALLPAPER@@" ]
          [ "${../theme/wallpapers/epoch-umber-lock.png}" ]
          (builtins.readFile ./sefirah-lock-dir/sefirah.py)}
      '';

      sefirah-lock = pkgs.writeShellScriptBin "sefirah-lock" ''
        cfg="$HOME/.config/sefirah/current/hypr/hyprlock.conf"
        if [ ! -f "$cfg" ]; then
          ${sefirah}/bin/sefirah transmute >/dev/null
        fi
        exec ${pkgs.hyprlock}/bin/hyprlock --config "$cfg" --immediate-render --no-fade-in "$@"
      '';
    in
    {
      home.packages = [
        sefirah
        sefirah-lock
        pkgs.imagemagick
      ];

      # Sefirah config
      xdg.configFile."sefirah/config.toml".text = ''
        [display]
        terminal_font = "vga"
        pixel_scale = 0

        [tarot]
        on_login = true
      '';

      # Generate hyprlock config at startup
      xdg.configFile."autostart/sefirah-transmute.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Sefirah Transmute
        Exec=sefirah transmute
        X-GNOME-Autostart-enabled=true
      '';
    })
  ];
}
