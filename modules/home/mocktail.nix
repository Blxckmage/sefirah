{ inputs, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [
        inputs.mocktail.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })
  ];
}
