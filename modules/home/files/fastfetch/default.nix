{ lib, ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."fastfetch" = {
        source = lib.cleanSourceWith {
          src = ./.;
          filter = path: _: baseNameOf path != "default.nix";
        };
        recursive = true;
      };
    }
  ];
}
