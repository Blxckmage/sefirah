{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        wget
      ];
    })
  ];
}
