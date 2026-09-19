{ ... }:
{
  config.sefirah.homeModules = [
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ status = \"on\" })'";
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "hyprlock";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ status = \"off\" })'";
              on-resume = "hyprctl dispatch 'hl.dsp.dpms({ status = \"on\" })'";
            }
          ];
        };
      };
    }
    ({ pkgs, ... }: {
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
