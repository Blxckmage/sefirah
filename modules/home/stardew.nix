{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, lib, ... }:
      let
        gameDir = "/home/blackmage/Games/Steam/steamapps/common/Stardew Valley";
        galaxyLibs = map (f: "${gameDir}/${f}") [
          "libGalaxy64.so"
          "libGalaxyCSharpGlue.so"
        ];

        fixScript = pkgs.writeShellScript "stardew-galaxy-execstack-fix" ''
          set -eu
          for f in ${lib.escapeShellArgs galaxyLibs}; do
            [ -e "$f" ] || continue
            ${lib.getExe' pkgs.prelink "execstack"} -c "$f"
          done
        '';
      in
      {
        systemd.user.services.stardew-galaxy-execstack = {
          Unit.Description = "Clear executable stack flag on Stardew Valley GOG Galaxy libraries";
          Service = {
            Type = "oneshot";
            ExecStart = fixScript;
          };
          Install.WantedBy = [ "default.target" ];
        };

        systemd.user.paths.stardew-galaxy-execstack = {
          Unit.Description = "Watch Stardew Valley GOG Galaxy libraries for Steam updates";
          Path.PathModified = galaxyLibs ++ [ gameDir ];
          Install.WantedBy = [ "default.target" ];
        };
      })
  ];
}
