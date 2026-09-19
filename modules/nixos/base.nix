{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      nix.settings = {
        extra-substituters = [ "https://blxckmage.cachix.org" ];
        extra-trusted-public-keys = [ "blxckmage.cachix.org-1:VXMamvKEyeu6CthXawUNSxcFB49to7r4tOWpFrWAR3s=" ];
      };

      nixpkgs.overlays = [
        (import ../../overlays/waybar-git.nix)
        (import ../../overlays/thinkfan-tui.nix)
      ];

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [ wget ];

      system.stateVersion = "26.05";
    })
  ];
}
