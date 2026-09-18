{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.power-profiles-daemon.enable = true;
    }
  ];
}
