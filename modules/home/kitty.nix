{ ... }:
{
  config.sefirah.homeModules = [
    {
      stylix.targets.kitty.enable = false;
      programs.kitty = {
        enable = true;
        settings = {
          shell = "zsh";
          disable_ligatures = "always";
          symbol_map = "U+E000-U+F8FF Symbols Nerd Font Mono";
          window_padding_width = 14;
          hide_window_decorations = "yes";
          confirm_os_window_close = "0";
          allow_remote_control = "no";
          cursor_shape = "block";
          enable_audio_bell = "no";
          shell_integration = "no-cursor";
          cursor_trail = 3;
          repaint_delay = 6;
          input_delay = 2;
          sync_to_monitor = "yes";
          tab_bar_edge = "bottom";
          tab_bar_style = "powerline";
          tab_powerline_style = "slanted";
          font_family = "Kode Mono";
          bold_font = "Kode Mono";
          font_size = 12;
          foreground = "#e3d6b8";
          background = "#16120e";
          selection_foreground = "#16120e";
          selection_background = "#e3d6b8";
          cursor = "#e3d6b8";
          cursor_text_color = "#16120e";
          color0 = "#16120e";
          color1 = "#d25f42";
          color2 = "#8f9a5a";
          color3 = "#d49a3a";
          color4 = "#7f93a8";
          color5 = "#a8707a";
          color6 = "#7aa08c";
          color7 = "#cfc1a3";
          color8 = "#8d7d65";
          color9 = "#dd7357";
          color10 = "#b0b878";
          color11 = "#e8bd6a";
          color12 = "#a3b3c2";
          color13 = "#c9939a";
          color14 = "#9fc0ab";
          color15 = "#f3ead3";
        };
        keybindings = {
          "ctrl+-" = "change_font_size all -2";
          "ctrl+=" = "change_font_size all +2";
        };
        extraConfig = "tab_title_template {title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      };
    }
  ];
}
