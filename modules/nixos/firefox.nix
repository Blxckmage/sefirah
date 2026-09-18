{ ... }:
{
  config.sefirah.nixosModules = [
    {
      programs.firefox.enable = true;
    }
  ];
}
