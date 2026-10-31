{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      nixpkgs.overlays = [
        (import ../../overlays/xwayland-satellite.nix)
      ];

      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    })
  ];
}
