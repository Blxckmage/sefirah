{ ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."waybar/style.css".source = ./files/waybar/style-epoch.css;
    }
  ];
}
