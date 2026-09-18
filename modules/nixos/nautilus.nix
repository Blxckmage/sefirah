{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.gvfs.enable = true;
      programs.dconf.enable = true;
    }
  ];
}
