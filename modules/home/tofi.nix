{ config, ... }:
let
  tc = config.sefirah.theme.withHashtag;
in
{
  config.sefirah.homeModules = [
    {
      stylix.targets.tofi.enable = false;
      programs.tofi = {
        enable = true;
        settings = {
          width = "100%";
          height = "100%";
          padding-left = "35%";
          padding-top = "28%";
          border-width = 0;
          outline-width = 0;
          num-results = 7;
          result-spacing = 18;
          font = "CaskaydiaMono Nerd Font";
          font-size = 16;
          background-color = tc.base00 + "D9";
          text-color = tc.base05 + "E6";
          prompt-color = tc.base0D;
          prompt-padding = 8;
          placeholder-text = "Type to filter…";
          placeholder-color = tc.base03;
          input-color = tc.base05;
          text-cursor-color = tc.base0B;
          selection-color = tc.base0B;
          selection-match-color = tc.base0A;
          selection-background = tc.base02 + "E6";
          selection-background-padding = "6,12";
          selection-background-corner-radius = 8;
          hide-cursor = true;
          exclusive-zone = -1;
          clip-to-padding = true;
        };
      };
    }
  ];
}
