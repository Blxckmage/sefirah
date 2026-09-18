{ config, inputs, ... }:
{
  flake.nixosConfigurations.sefirah = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = config.sefirah.nixosModules ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      ../../hardware-configuration.nix
      {
        networking.hostName = "sefirah";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.users.blackmage.imports =
          config.sefirah.homeModules ++ [ inputs.sops-nix.homeManagerModules.sops ];
      }
    ];
  };
}
