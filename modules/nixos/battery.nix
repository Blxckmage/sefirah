{ ... }:
{
  config.sefirah.nixosModules = [
    {
      systemd.services.battery-thresholds = {
        description = "ThinkPad charge thresholds (longevity band)";
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
          echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
        '';
      };
    }
  ];
}
