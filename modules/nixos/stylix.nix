{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      stylix = {
        enable = true;
        enableReleaseChecks = false;
        polarity = "dark";
        base16Scheme = ../theme/everforest-dark-hard.yaml;
        image = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/Gurjaka/Everforest-Wallpapers/main/wallpapers/fog_forest_alt_1.png";
          hash = "sha256-IeQzvScaS107R+639JzH/Jaxo4Vp0G+wpAm3ufoYHbY=";
        };
        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.caskaydia-mono;
            name = "CaskaydiaMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.cantarell-fonts;
            name = "Cantarell";
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
