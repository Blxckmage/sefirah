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
      };

      nixpkgs.overlays = [
        (import ../../overlays/waybar-git.nix)
        (import ../../overlays/thinkfan-tui.nix)
        (import ../../overlays/9router.nix)
        (import ../../overlays/sefirah.nix)
      ];

      nixpkgs.config.allowUnfree = true;

      # nh clean owns garbage collection (nixpkgs warns if nix.gc is
      # also enabled, so nix.gc stays off).
      programs.nh = {
        enable = true;
        flake = "/home/blackmage/.config/nixpkgs";
        clean.enable = true;
      };


      environment.systemPackages = with pkgs; [ wget ];

      system.stateVersion = "26.05";
    })
  ];
}
