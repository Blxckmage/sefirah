{ ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."waybar/config".source = ./config.jsonc;
    }
  ];
}
