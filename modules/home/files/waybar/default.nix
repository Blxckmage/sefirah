{ ... }:
{
  config.sefirah.homeModules = [
    {
      # Niri is the only compositor: install its bar as the default config
      # that the waybar user service (see services.nix) reads at startup.
      xdg.configFile."waybar/config".source = ./config-niri.jsonc;
    }
  ];
}
