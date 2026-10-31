{ ... }:
{
  config.sefirah.homeModules = [
    ({ config, ... }:
    let
      tc = config.lib.stylix.colors.withHashtag;
    in
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
          font = "PxPlus IBM VGA 8x16";
          font-size = 16;
          background-color = tc.base00 + "D9";
          text-color = tc.base05 + "E6";
          prompt-color = tc.base09;
          prompt-padding = 8;
          placeholder-text = "Type to filter…";
          placeholder-color = tc.base03;
          input-color = tc.base05;
          text-cursor-color = tc.base0B;
          selection-color = tc.base0B;
          selection-match-color = tc.base09;
          selection-background = tc.base02 + "E6";
          selection-background-padding = "6,12";
          selection-background-corner-radius = 0;
          hide-cursor = true;
          exclusive-zone = -1;
          clip-to-padding = true;
        };
      };
    })
  ];
}
