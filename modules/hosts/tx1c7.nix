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
      ({ pkgs, ... }: {
        services.thermald.enable = false;

        # Kyber I/O scheduler: 2ms read-latency target keeps interactive
        # reads flowing under write floods.
        # NOTE: both AC and battery stay on `balanced`. The old udev rule
        # pinned AC to `performance` (max_perf 100% + turbo), which removed
        # all thermal headroom on this thin chassis. Switch to
        # `performance` manually via power-profile-tofi when needed.
        services.udev.extraRules = ''
          ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*|sd*|mmcblk*|vd*", ATTR{queue/scheduler}="kyber"
          SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
          SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
        '';
        systemd.services.powerprofiles-init = {
          description = "Set power profile from AC state at boot";
          # Runs after boot is complete instead of ordering against
          # power-profiles-daemon.service: the old
          # wants/after + wantedBy multi-user.target created an ordering
          # cycle and systemd deleted this job at every boot
          # ("Job powerprofiles-init.service/start deleted to break
          # ordering cycle").
          wantedBy = [ "multi-user.target" ];
          after = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = ''
            for i in $(seq 1 30); do
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced && break
              sleep 1
            done
          '';
        };

        # Game-aware auto-nice daemon with CachyOS's ruleset. If it ever
        # fights gamemode's renice on FM24, disable this first.
        services.ananicy = {
          enable = true;
          package = pkgs.ananicy-cpp;
          rulesProvider = pkgs.ananicy-rules-cachyos;
        };

        # Transparent Huge Pages: always (CachyOS-style). Helps tcmalloc
        # apps like Chromium and Proton/Wine games; costs some RAM.
        systemd.tmpfiles.rules = [
          "w /sys/kernel/mm/transparent_hugepage/enabled - - - - always"
        ];
      })
    ];
  };
}
