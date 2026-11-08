{ ... }:
{
  config.sefirah.nixosModules = [
    {
      # Manual fan control. Full user control — fan stays where you set it.
      boot.extraModprobeConfig = ''
        options thinkpad_acpi fan_control=1
      '';

      # Enable manual fan mode at boot (fan starts disabled by default).
      systemd.services.fan-enable = {
        description = "Enable ThinkPad manual fan control";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
          fan=/proc/acpi/ibm/fan
          for _ in $(seq 1 30); do
            if [ -w "$fan" ]; then
              echo enable > "$fan"
              break
            fi
            sleep 1
          done
        '';
      };

      # Kernel watchdog OFF (0) — you control fan entirely.
      systemd.services.fan-watchdog = {
        description = "Disable ThinkPad fan kernel watchdog (EC handles safety)";
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

      # Keep-alive: re-assert level 0 every 1s so EC firmware doesn't override.
      # This is what keeps the fan at 0 (off) until YOU change it.
      systemd.services.fan-keepalive = {
        description = "Keep fan at level 0 (off) — re-assert every 1s to prevent EC override";
        wantedBy = [ "multi-user.target" ];
        after = [ "fan-enable.service" "fan-watchdog.service" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 1;
          ExecStart = "/bin/sh -c 'while true; do echo \"level 0\" > /proc/acpi/ibm/fan; sleep 1; done'";
        };
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

      systemd.services.fan-level-restore = {
        description = "Restore ThinkPad fan level after resume";
        after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          if [ -s /run/fan-level ]; then
            echo "level $(cat /run/fan-level)" > /proc/acpi/ibm/fan
            rm -f /run/fan-level
          fi
        '';
      };

      # NO thinkfan daemon — you have full manual control via thinkfan-tui.
    }
  ];
}