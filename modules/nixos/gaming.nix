{ ... }:
{
  config.sefirah.nixosModules = [
    {
      programs.gamescope.enable = true;
      programs.gamemode.enable = true;
    }
  ];
}
