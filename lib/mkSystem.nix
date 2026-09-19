{ inputs }:
{ system, hostname, nixosModules ? [ ], homeModules ? [ ] }:
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    { networking.hostName = hostname; }
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.blackmage.imports = homeModules;
    }
  ] ++ nixosModules;
}
