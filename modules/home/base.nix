{ ... }:
{
  config.sefirah.homeModules = [
    ({ lib, ... }: {
      home.username = "blackmage";
      home.homeDirectory = "/home/blackmage";

      home.activation.clearTofiDrunCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        rm -f "$HOME/.cache/tofi-drun"
      '';

      programs.home-manager.enable = true;
      programs.bash.enable = true;

      home.stateVersion = "26.05";    })
  ];
}
