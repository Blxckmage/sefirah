{ lib, ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."nvim" = {
        source = lib.cleanSourceWith {
          src = ./.;
          filter = path: _: baseNameOf path != "default.nix";
        };
        recursive = true;
      };
    }
  ];
}
