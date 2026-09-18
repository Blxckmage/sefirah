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
    })
  ];
}
