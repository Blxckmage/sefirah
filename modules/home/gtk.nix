{ ... }:
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
        theme = {
          name = "Everforest-Dark";
          package = pkgs.everforest-gtk-theme;
        };
        iconTheme = {
          name = "Tela-green-dark";
          package = pkgs.tela-icon-theme;
        };
        gtk3.extraConfig.gtk-cursor-theme-name = "Bibata-Modern-Classic";
        gtk4.extraConfig.gtk-cursor-theme-name = "Bibata-Modern-Classic";
      };
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Everforest-Dark";
        icon-theme = "Tela-green-dark";
        cursor-theme = "Bibata-Modern-Classic";
      };
      # libadwaita (Nautilus) ignores the system GTK theme; it only reads
      # ~/.config/gtk-4.0/gtk.css, so link the theme file + its assets there.
      xdg.configFile."gtk-4.0/gtk.css".source = "${pkgs.everforest-gtk-theme}/share/themes/Everforest-Dark/gtk-4.0/gtk.css";
      xdg.configFile."gtk-4.0/assets" = {
        source = "${pkgs.everforest-gtk-theme}/share/themes/Everforest-Dark/gtk-4.0/assets";
        recursive = true;
      };
    })
  ];
}
