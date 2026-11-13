{
  description = "sefirah — dendritic NixOS + Home Manager";

  inputs = {
    # shortcut: brave dropped from nixos-unstable 2026-11-03; this is the last
    # unstable snapshot with it. Revert to nixos-unstable once #584534 lands there.
    nixpkgs.url = "github:NixOS/nixpkgs/2591f65879e995cb99e023c8d3b6ec5b758150c4";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    omp.url = "github:can1357/oh-my-pi";
    omp.inputs.nixpkgs.follows = "nixpkgs";
    luvus.url = "github:RizRiyz/luvus";
    luvus.inputs.nixpkgs.follows = "nixpkgs";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    spotifast.url = "github:crmne/spotifast";
    spotifast.inputs.nixpkgs.follows = "nixpkgs";
    mocktail.url = "github:komaruworld/mocktail";
  };

  outputs = inputs:
  let
    modules = (inputs.import-tree ./modules) { filter = inputs.import-tree.initFilter; };
    flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      # den used to set this implicitly; perSystem outputs need it.
      systems = [ "x86_64-linux" ];
      imports = [ modules ];
    };
  in
  {
    apps = flake.apps;
    checks = flake.checks;
    devShells = flake.devShells;
    formatter = flake.formatter;
    legacyPackages = flake.legacyPackages;
    nixosConfigurations = flake.nixosConfigurations;
    nixosModules = flake.nixosModules;
    overlays = flake.overlays;
    packages = flake.packages;
  };
}
