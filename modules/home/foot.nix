{ ... }:
{
  config.sefirah.homeModules = [
    {
      stylix.targets.foot.enable = false;
      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "Kode Mono:pixelsize=16,Symbols Nerd Font Mono:pixelsize=12:antialias=false:rgba=none";
            "font-bold" = "Kode Mono:pixelsize=16,Symbols Nerd Font Mono:pixelsize=12:antialias=false:rgba=none";
            pad = "14x14";
            "dpi-aware" = "no";
          };
          cursor = {
            style = "block";
            blink = "yes";
          };
          mouse = {
            "hide-when-typing" = "yes";
          };
          "colors-dark" = {
            foreground = "e3d6b8";
            background = "16120e";
            "selection-foreground" = "16120e";
            "selection-background" = "e3d6b8";
            cursor = "16120e e3d6b8";
            regular0 = "16120e";
            regular1 = "d25f42";
            regular2 = "8f9a5a";
            regular3 = "d49a3a";
            regular4 = "7f93a8";
            regular5 = "a8707a";
            regular6 = "7aa08c";
            regular7 = "cfc1a3";
            bright0 = "8d7d65";
            bright1 = "dd7357";
            bright2 = "b0b878";
            bright3 = "e8bd6a";
            bright4 = "a3b3c2";
            bright5 = "c9939a";
            bright6 = "9fc0ab";
            bright7 = "f3ead3";
          };
          "colors-light" = {
            foreground = "e3d6b8";
            background = "16120e";
            "selection-foreground" = "16120e";
            "selection-background" = "e3d6b8";
            cursor = "16120e e3d6b8";
            regular0 = "16120e";
            regular1 = "d25f42";
            regular2 = "8f9a5a";
            regular3 = "d49a3a";
            regular4 = "7f93a8";
            regular5 = "a8707a";
            regular6 = "7aa08c";
            regular7 = "cfc1a3";
            bright0 = "8d7d65";
            bright1 = "dd7357";
            bright2 = "b0b878";
            bright3 = "e8bd6a";
            bright4 = "a3b3c2";
            bright5 = "c9939a";
            bright6 = "9fc0ab";
            bright7 = "f3ead3";
          };
        };
      };
    }
  ];
}
