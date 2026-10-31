{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.hypridle ];

      xdg.configFile."hypr/hypridle.conf".text = ''
        general {
            lock_cmd = hyprlock --config ~/.config/hypr/hyprlock.conf
            before_sleep_cmd = loginctl lock-session
            after_sleep_cmd = hyprctl dispatch dpms on
        }

        listener {
            timeout = 600
            on-timeout = loginctl lock-session
        }

        listener {
            timeout = 900
            on-timeout = hyprctl dispatch dpms off
            on-resume = hyprctl dispatch dpms on
        }
      '';
    })
  ];
}
