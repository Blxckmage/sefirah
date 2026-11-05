{ ... }:
{
  config.sefirah.nixosModules = [
    {
      # Manual fan control. Thermal safety via thermald + power cap.
      boot.extraModprobeConfig = ''
        options thinkpad_acpi fan_control=1
      '';

      systemd.services.fan-watchdog-off = {
        description = "Keep the ThinkPad fan under full manual control";
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

      # Preserve manual fan level across suspend/resume.
      systemd.services.fan-level-save = {
        description = "Remember the ThinkPad fan level before suspend";
        before = [ "sleep.target" ];
        wantedBy = [ "sleep.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          level=$(grep '^level:' /proc/acpi/ibm/fan | sed 's/^level:[[:space:]]*//')
          case "$level" in
            0|1|2|3|4|5|6|7|disengaged|full-speed)
              echo "$level" > /run/fan-level
              ;;
            *)
              rm -f /run/fan-level
              ;;
          esac
        '';
      };

      powerManagement.resumeCommands = ''
        if [ -s /run/fan-level ]; then
          echo "level $(cat /run/fan-level)" > /proc/acpi/ibm/fan
        fi
      '';
    }
  ];
}
