{ ... }:
{
  config.sefirah.nixosModules = [
    {
      boot.extraModprobeConfig = ''
        options thinkpad_acpi fan_control=1
      '';

      systemd.services.fan-watchdog-off = {
        description = "Disable the thinkpad_acpi fan safety watchdog";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          fan_watchdog=/sys/bus/platform/drivers/thinkpad_hwmon/fan_watchdog
          for _ in $(seq 1 30); do
            if [ -w "$fan_watchdog" ]; then
              echo 0 > "$fan_watchdog"
              break
            fi
            sleep 1
          done
        '';
      };
    }
  ];
}
