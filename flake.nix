{
  description = "sefirah — dendritic NixOS + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    den.url = "github:denful/den/bf2504f9f2e8621fee091335132ab3ae698cf808";
    den-diagram.url = "github:denful/den-diagram/268bdbd9678ca3afab4ccbf40c76cf90b6205e2b";
  };

  outputs = { self, nixpkgs, flake-parts, import-tree, home-manager, nixos-hardware, stylix, llm-agents, omp, luvus, nix-flatpak, nixCats, spotifast, mocktail, den, ... }@inputs:
  let
    denDiagram = builtins.getAttr "den-diagram" inputs;
    flakeInputs = inputs // { "den-diagram" = denDiagram; };
    flake = flakeInputs.flake-parts.lib.mkFlake { inputs = flakeInputs; } (flakeInputs.import-tree ./modules { filter = flakeInputs.import-tree.initFilter; });
  in
  flake // {
    denDiagrams-mermaid = flake.diagrams.tx1c7-mermaid;
  };
}
