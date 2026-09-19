{ lib, ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."zsh" = {
        source = lib.cleanSourceWith {
          src = ./.;
          filter = path: _: baseNameOf path != "default.nix";
        };
        recursive = true;
      };
    }
  ];
}
