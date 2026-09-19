{ ... }:
{
  config.sefirah.nixosModules = [
    {
      boot.plymouth.enable = true;
      boot.kernelParams = [
        "quiet"
        "splash"
        "loglevel=3"
      ];
    }
  ];
}
