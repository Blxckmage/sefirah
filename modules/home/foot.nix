{ ... }:
{
  config.sefirah.homeModules = [
    {
      stylix.targets.foot.enable = true;
      programs.foot = {
        enable = true;
        settings.main.dpi-aware = "no";
      };
    }
  ];
}
