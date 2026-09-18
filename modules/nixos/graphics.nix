{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
      ];
    })
  ];
}
