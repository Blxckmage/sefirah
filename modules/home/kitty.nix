{ config, ... }:
let
  tc = config.sefirah.theme.withHashtag;
in
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."kitty/theme.d/everforest.conf".text = with tc; ''
        background ${base00}
        foreground ${base05}
        selection_background ${base02}
        selection_foreground ${base05}
        url_color ${base0D}
        cursor ${base05}
        cursor_text_color ${base00}
        active_border_color ${base0D}
        inactive_border_color ${base01}
        bell_border_color ${base0A}
        active_tab_foreground ${base05}
        active_tab_background ${base02}
        inactive_tab_foreground ${base04}
        inactive_tab_background ${base01}
        color0 ${base00}
        color1 ${base08}
        color2 ${base0B}
        color3 ${base0A}
        color4 ${base0D}
        color5 ${base0E}
        color6 ${base0C}
        color7 ${base05}
        color8 ${base03}
        color9 ${base08}
        color10 ${base0B}
        color11 ${base0A}
        color12 ${base0D}
        color13 ${base0E}
        color14 ${base0C}
        color15 ${base07}
        color16 ${base09}
        color17 ${base0F}
        color18 ${base01}
        color19 ${base02}
        color20 ${base04}
        color21 ${base06}
      '';
    }
  ];
}
