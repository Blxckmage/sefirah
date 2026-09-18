{ config, ... }:
let
  tc = config.sefirah.theme.withHashtag;
in
{
  config.sefirah.homeModules = [
    {
      services.mako = {
        enable = true;
        settings = {
          anchor = "top-right";
          group-by = "app-name,summary,body";
          default-timeout = 5000;
          width = 420;
          outer-margin = 20;
          padding = "10,15";
          border-size = 2;
          max-icon-size = 32;
          font = "monospace 11";
          background-color = tc.base00;
          text-color = tc.base05;
          border-color = tc.base0B;
          border-radius = 6;
        };
        extraConfig = ''
          [urgency=critical]
          default-timeout=0
          layer=overlay

          [mode=do-not-disturb]
          invisible=true

          [mode=do-not-disturb app-name=notify-send]
          invisible=false
        '';
      };
    }
  ];
}
