{ config, ... }:
{
  config.sefirah.homeModules = [
    {
      programs.btop = {
        enable = true;
        settings.color_theme = "everforest";
        themes.everforest = config.sefirah.theme.btopTheme;
      };
    }
  ];
}
