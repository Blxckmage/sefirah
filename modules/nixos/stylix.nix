{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      stylix = {
        enable = true;
        enableReleaseChecks = false;
        polarity = "dark";
        base16Scheme = ../theme/epoch.yaml;
        image = ../theme/wallpapers/epoch-umber-desk-1.png;
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.caskaydia-mono;
            name = "CaskaydiaMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.nerd-fonts.caskaydia-mono;
            name = "CaskaydiaMono Nerd Font";
          };
          serif = {
            package = pkgs.dejavu_fonts;
            name = "DejaVu Serif";
          };
          sizes = {
            terminal = 11;
            applications = 11;
            popups = 11;
            desktop = 12;
          };
        };
        cursor = {
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 16;
        };
        autoEnable = false;
        targets = {
          plymouth.enable = true;
          fontconfig.enable = true;
          font-packages.enable = true;
        };
      };

      fonts.fontconfig = {
        antialias = true;
        hinting.enable = true;
        hinting.style = "full";
        subpixel.rgba = "rgb";
        subpixel.lcdfilter = "default";
      };
    })
  ];
}
