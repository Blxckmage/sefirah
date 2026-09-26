{ ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."waybar/config".source = ./config.jsonc;
      # Niri bar: same modules, niri/workspaces instead of hyprland/workspaces.
      # Selected at runtime by the waybar-session wrapper (see services.nix).
      xdg.configFile."waybar/config-niri".source = ./config-niri.jsonc;
    }
  ];
}
