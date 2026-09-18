{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      users.users."blackmage" = {
        isNormalUser = true;
        description = "Faza Zikri";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };

      programs.zsh.enable = true;
    })
  ];
}
