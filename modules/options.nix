{ lib, ... }:
{
  options.sefirah.theme = lib.mkOption {
    type = lib.types.attrs;
    description = "Single ThemeNix palette for the whole setup.";
  };

  options.sefirah.nixosModules = lib.mkOption {
    type = lib.types.listOf lib.types.deferredModule;
    default = [ ];
    description = "NixOS modules composed into every sefirah host.";
  };

  options.sefirah.homeModules = lib.mkOption {
    type = lib.types.listOf lib.types.deferredModule;
    default = [ ];
    description = "Home Manager modules composed into the blackmage user.";
  };
}
