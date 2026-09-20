{ ... }:
{
  config.sefirah.homeModules = [
    ({ config, lib, ... }:
    let
      tc = config.lib.stylix.colors.withHashtag;
      hx = hex: lib.toLower (lib.removePrefix "#" hex);
    in
    {
      xdg.configFile."hypr/theme/colors.lua".text = ''
        -- Generated from Stylix palette. Do not hand-edit.
        return {
          active_border = { colors = { "rgba(${hx tc.base0D}ee)", "rgba(${hx tc.base0B}ee)" }, angle = 45 },
          inactive_border = "rgba(${hx tc.base02}aa)",
          group_text = "rgb(${hx tc.base05})",
          group_text_inactive = "rgba(${hx tc.base05}90)",
        }
      '';
    })
  ];
}
