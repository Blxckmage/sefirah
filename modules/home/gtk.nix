{ config, lib, ... }:
let
  tc = config.sefirah.theme.withHashtag;
  hexDigit = {
    "0" = 0; "1" = 1; "2" = 2; "3" = 3;
    "4" = 4; "5" = 5; "6" = 6; "7" = 7;
    "8" = 8; "9" = 9; "a" = 10; "b" = 11;
    "c" = 12; "d" = 13; "e" = 14; "f" = 15;
  };
  hexByte = s: let
    chars = lib.stringToCharacters (lib.toLower s);
    d = c: hexDigit.${c};
  in (d (builtins.elemAt chars 0)) * 16 + d (builtins.elemAt chars 1);
  rgb = hex: let h = lib.removePrefix "#" hex; in
    "${toString (hexByte (builtins.substring 0 2 h))},${
      toString (hexByte (builtins.substring 2 2 h))},${
      toString (hexByte (builtins.substring 4 2 h))}";
in
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };
      gtk = {
        enable = true;
        cursorTheme = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
        };
        gtk3.extraConfig.gtk-cursor-theme-name = "Bibata-Modern-Classic";
        gtk4.extraConfig.gtk-cursor-theme-name = "Bibata-Modern-Classic";
      };
      qt = {
        enable = true;
        platformTheme.name = "kvantum";
        style.name = "kvantum";
      };
    })
    {
      xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=MateriaEverforestDark
      '';
      xdg.configFile."kdeglobals".text = with tc; ''
        [General]
        ColorScheme=EverforestDarkHard
        Name=EverforestDarkHard

        [Icons]
        Theme=Tela-green-dark

        [Colors:View]
        BackgroundNormal=${rgb base00}
        ForegroundNormal=${rgb base05}
        ForegroundInactive=${rgb base03}
        BackgroundAlternate=${rgb base01}
        ForegroundLink=${rgb base0D}
        ForegroundVisited=${rgb base0E}
        ForegroundActive=${rgb base0B}
        ForegroundNegative=${rgb base08}
        ForegroundNeutral=${rgb base0A}
        ForegroundPositive=${rgb base0B}

        [Colors:Window]
        BackgroundNormal=${rgb base00}
        ForegroundNormal=${rgb base05}
        ForegroundInactive=${rgb base03}
        BackgroundAlternate=${rgb base01}
        ForegroundLink=${rgb base0D}
        ForegroundActive=${rgb base0B}
        ForegroundNegative=${rgb base08}
        ForegroundNeutral=${rgb base0A}
        ForegroundPositive=${rgb base0B}

        [Colors:Selection]
        BackgroundNormal=${rgb base0B}
        ForegroundNormal=${rgb base00}
        BackgroundAlternate=${rgb base0D}
        ForegroundInactive=${rgb base03}

        [Colors:Button]
        BackgroundNormal=${rgb base01}
        ForegroundNormal=${rgb base05}
        BackgroundAlternate=${rgb base02}
        ForegroundInactive=${rgb base03}
      '';
    }
  ];
}
