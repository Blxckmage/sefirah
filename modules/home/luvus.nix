{ inputs, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [
        inputs.luvus.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })
  ];
}
