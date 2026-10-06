{ inputs, self, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.nvim
      ];
    })
  ];
}
