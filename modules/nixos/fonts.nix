{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }:
    let
      jacquard24 = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/google/fonts/main/ofl/jacquard24/Jacquard24-Regular.ttf";
        hash = "sha256-jlsb24tgh9YXXx2e3SY044sQ+xCcCVXCStVScqhm7Uk=";
      };
    in
    {
      fonts.packages = with pkgs; [
        ultimate-oldschool-pc-font-pack
        kode-mono
        terminus_font_ttf
        cozette
        lxgw-wenkai-screen
        nerd-fonts.symbols-only
        (runCommand "jacquard-24" { } ''
          install -Dm644 ${jacquard24} $out/share/fonts/truetype/Jacquard24-Regular.ttf
        '')
      ];

      fonts.fontconfig.localConf = builtins.readFile ../theme/60-epoch.conf;
    })
  ];
}
