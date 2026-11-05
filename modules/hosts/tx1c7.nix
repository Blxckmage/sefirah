{ config, inputs, ... }:
let
  mkSystem = import ../../lib/mkSystem.nix { inherit inputs; };
in
{
  flake.nixosConfigurations.sefirah = mkSystem {
    system = "x86_64-linux";
    hostname = "sefirah";
    homeModules = config.sefirah.homeModules;
    nixosModules = config.sefirah.nixosModules ++ [
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      ../../hardware-configuration.nix
      # Kept host-specific: other machines get their own sizing.
      {
        zramSwap = {
          enable = true;
          memoryPercent = 100;
          algorithm = "zstd";
          priority = 100;
        };

        # zswap in front of swap-on-zram just wastes cycles (Omarchy disables it too).
        boot.kernelParams = [ "zswap.enabled=0" ];

        # Omarchy's reclaim tuning for swap-on-zram (disk-era defaults assume slow swap).
        boot.kernel.sysctl = {
          "vm.swappiness" = 150;
          "vm.vfs_cache_pressure" = 50;
          "vm.page-cluster" = 0;
          "vm.watermark_boost_factor" = 0;
          "vm.watermark_scale_factor" = 125;
          "vm.dirty_background_bytes" = 67108864;
          "vm.dirty_bytes" = 268435456;
          "vm.dirty_writeback_centisecs" = 1500;
          # CachyOS: fewer timer interrupts and wakeups.
          "kernel.nmi_watchdog" = 0;
        };
      }
      ({ config, pkgs, ... }: {
        # Manual fan + thermald backstop, power capped for passive cooling.
        services.thermald.enable = true;

        systemd.services.cpu-power-cap = {
          description = "Cap Intel RAPL package power for manual-fan use";
          wantedBy = [ "multi-user.target" ];
          wants = [ "power-profiles-daemon.service" ];
          after = [
            "power-profiles-daemon.service"
            "thermald.service"
          ];
          path = [ pkgs.coreutils ];
          serviceConfig.Type = "oneshot";
          script = ''
            set -euo pipefail
            rapl=/sys/class/powercap/intel-rapl:0
            for _ in $(seq 1 30); do
              if [ -w "$rapl/constraint_0_power_limit_uw" ]; then
                break
              fi
              sleep 1
            done
            echo 10000000 > "$rapl/constraint_0_power_limit_uw"
            echo 15000000 > "$rapl/constraint_1_power_limit_uw"
            echo "cpu-power-cap: PL1=$(cat "$rapl/constraint_0_power_limit_uw") PL2=$(cat "$rapl/constraint_1_power_limit_uw")"
          '';
        };

        # Re-apply in case PPD/thermald rewrites the RAPL limits later.
        systemd.timers.cpu-power-cap = {
          description = "Re-apply the manual-fan CPU power cap";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "2min";
            OnUnitActiveSec = "5min";
            Unit = "cpu-power-cap.service";
          };
        };

        # Both AC and battery stay on `balanced`. Switch to `performance`
        # manually via power-profile-tofi when needed.
        #------------------
        # services.udev.extraRules = ''
        #   ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*|sd*|mmcblk*|vd*", ATTR{queue/scheduler}="kyber"
        #   SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
        #   SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
        #   SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${config.systemd.package}/bin/systemctl --no-block restart cpu-power-cap.service"
        #   SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${config.systemd.package}/bin/systemctl --no-block restart cpu-power-cap.service"
        # '';
        #------------------
        # systemd.services.powerprofiles-init = {
        #   description = "Set power profile from AC state at boot";
        #   # Runs after boot is complete instead of ordering against
        #   # power-profiles-daemon.service: the old
        #   # wants/after + wantedBy multi-user.target created an ordering
        #   # cycle and systemd deleted this job at every boot
        #   # ("Job powerprofiles-init.service/start deleted to break
        #   # ordering cycle").
        #   wantedBy = [ "multi-user.target" ];
        #   after = [ "multi-user.target" ];
        #   serviceConfig.Type = "oneshot";
        #   script = ''
        #     for i in $(seq 1 30); do
        #       ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced && break
        #       sleep 1
        #     done
        #   '';
        # };
        #------------------

        # Game-aware auto-nice daemon with CachyOS ruleset.
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };

        # THP always enabled (CachyOS). Helps Chromium/Proton, costs some RAM.
        systemd.tmpfiles.rules = [
          "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
        ];
      })
    ];
  };
}
