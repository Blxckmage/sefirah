{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }:
    {
      systemd.user.services.waybar = {
        Unit = {
          Description = "Highly customizable Wayland bar";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.waybar}/bin/waybar";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
  ];
}
