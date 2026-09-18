{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      fonts.packages = with pkgs; [
        nerd-fonts.fira-mono
        nerd-fonts.caskaydia-mono
      ];
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
