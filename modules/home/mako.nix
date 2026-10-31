{ ... }:
{
  config.sefirah.homeModules = [
    {
      stylix.targets.mako.enable = false;
      services.mako = {
        enable = true;
        settings = {
          anchor = "top-left";
          width = 1600;
          height = 24;
          max-visible = 1;
          icons = 0;
          format = "%s: %b";
          font = "PxPlus IBM VGA 8x16 12";
          background-color = "#0d0b08";
          text-color = "#cfc1a3";
          border-size = 0;
          border-radius = 0;
          padding = "3,12";
          margin = 0;
          outer-margin = 0;
          default-timeout = 8000;
        };
        extraConfig = ''
          [body=""]
          format=%s

          [urgency=critical]
          text-color=#dd7357
          default-timeout=0
          layer=overlay

          [hidden]
          format=<span background="#cfc1a3" foreground="#0d0b08">--More--</span> (%h)

          [mode=do-not-disturb]
          invisible=true

          [mode=do-not-disturb app-name=notify-send]
          invisible=false
        '';
      };
    }
  ];
}
