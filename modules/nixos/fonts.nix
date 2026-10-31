{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      fonts.packages = with pkgs; [
        ultimate-oldschool-pc-font-pack
        terminus_font_ttf
        cozette
        nerd-fonts.symbols-only
      ];

      fonts.fontconfig.localConf = builtins.readFile ../theme/60-epoch.conf;
    })
  ];
}
