{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.fwupd.enable = true;
    }
  ];
}
