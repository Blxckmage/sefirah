{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [
        (pkgs.writeScriptBin "epoch-sky" ''
          #!${pkgs.python3}/bin/python3
          ${builtins.readFile ./files/epoch-sky.py}
        '')
      ];
    })
  ];
}
