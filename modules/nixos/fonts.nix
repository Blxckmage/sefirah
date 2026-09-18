{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      fonts.packages = with pkgs; [
        nerd-fonts.fira-mono
        nerd-fonts.caskaydia-mono
      ];
    })
  ];
}
