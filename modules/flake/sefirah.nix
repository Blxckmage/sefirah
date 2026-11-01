{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      sefirah = pkgs.callPackage ../../pkgs/sefirah { };
    in
    {
      packages = {
        inherit sefirah;
        default = sefirah;
      };
    };
}
