{ ... }:
{
  config.sefirah.homeModules = [
    ({ config, pkgs, ... }:
    let
      lock = "${config.home.profileDirectory}/bin/sefirah-lock";
      niri = "${pkgs.niri}/bin/niri";
    in
    {
      home.packages = [ pkgs.hypridle ];

      services.hypridle = {
        enable = true;
        systemdTarget = "graphical-session.target";
        settings = {
          general = {
            lock_cmd = lock;
            before_sleep_cmd = lock;
            after_sleep_cmd = "${niri} msg action power-on-monitors";
          };

          listener = [
            {
              timeout = 600;
              on-timeout = lock;
            }
            {
              timeout = 900;
              on-timeout = "${niri} msg action power-off-monitors";
              on-resume = "${niri} msg action power-on-monitors";
            }
          ];
        };
      };
    })
  ];
}
