{ config, lib, ... }:
let
  cfg = config.sefirah.program;
in
{
  options.sefirah.program.enable = lib.mkEnableOption "program";
  config.sefirah.nixosModules = lib.mkIf cfg.enable [ { } ];
}
