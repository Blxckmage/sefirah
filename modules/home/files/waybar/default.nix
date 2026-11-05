{ ... }:
{
  config.sefirah.homeModules = [
    {
      # Niri is the only compositor: install its bar as the default config
      # that the waybar user service (see services.nix) reads at startup.
      xdg.configFile."waybar/config".source = ./config-epoch.jsonc;
      xdg.configFile."waybar/clock" = {
        source = ./clock;
        executable = true;
      };
      xdg.configFile."waybar/clock-toggle" = {
        source = ./clock-toggle;
        executable = true;
      };
    }
  ];
}
