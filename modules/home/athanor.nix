{ pkgs, lib, ... }:
{
  config.sefirah.homeModules = [
    ({ config, pkgs, lib, ... }: let
      athanor = pkgs.python3Packages.buildPythonPackage rec {
        pname = "athanor";
        version = "0.2.0";
        src = /home/blackmage/Projects/scratch/athanor;
        format = "pyproject";
        nativeBuildInputs = [ pkgs.hatchling ];
        propagatedBuildInputs = with pkgs.python3Packages; [];
        buildInputs = with pkgs; [ imagemagick python3Packages.pillow ];
        doCheck = false;
        meta = with lib; {
          description = "An alchemical layer for Hyprland";
          homepage = "https://github.com/blackmage/athanor";
          license = licenses.mit;
          maintainers = [ ];
        };
      };
    in {
      home.packages = [ athanor pkgs.imagemagick ];

      # Athanor config with Epoch/Umber settings
      xdg.configFile."athanor/athanor.toml".text = ''
        [character]
        name = "sefirah"
        title = "the Wizard"
        race = ""

        [room]
        name = "A Dim Chamber"
        description = "Dust hangs in the lamplight. A terminal hums on the desk."
        exits = {}

        [place]
        # latitude = 0.0
        # longitude = 0.0

        [display]
        terminal_font = "vga"
        pixel_scale = 0
        levels = true

        [transmute]
        stages = false

        [tarot]
        on_login = true
      '';

      # Run athanor transmute at startup to generate lock screen assets
      xdg.configFile."autostart/athanor-transmute.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Athanor Transmute
        Exec=${athanor}/bin/athanor transmute umber
        X-GNOME-Autostart-enabled=true
      '';
    })
  ];
}
