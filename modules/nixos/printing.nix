{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.printing.enable = true;
    }
  ];
}
