{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      programs.steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
      };
    })
  ];
}
