{ ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile = {
        "hypr/autostart.lua".source = ./autostart.lua;
        "hypr/envs.lua".source = ./envs.lua;
        "hypr/helper.lua".source = ./helper.lua;
        "hypr/hyprland.lua".source = ./hyprland.lua;
        "hypr/input.lua".source = ./input.lua;
        "hypr/looknfeel.lua".source = ./looknfeel.lua;
        "hypr/monitors.lua".source = ./monitors.lua;
        "hypr/windows.lua".source = ./windows.lua;
        "hypr/bindings".source = ./bindings;
        "hypr/scripts".source = ./scripts;
      };
    }
  ];
}
