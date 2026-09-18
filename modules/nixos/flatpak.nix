{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.flatpak.enable = true;
    }
  ];
}
