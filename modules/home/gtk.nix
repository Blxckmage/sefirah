{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      stylix.targets.gtk.enable = true;
      gtk = {
        enable = true;
        cursorTheme = {
          name = "Bibata-Modern-Classic";
          package = pkgs.bibata-cursors;
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
        gtk-theme = "adw-gtk3";
        icon-theme = "Tela-green-dark";
        cursor-theme = "Bibata-Modern-Classic";
        text-scaling-factor = 1.25;
      };
    })
  ];
}
