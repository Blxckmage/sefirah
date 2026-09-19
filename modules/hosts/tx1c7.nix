{ config, inputs, ... }:
{
  flake.nixosConfigurations.sefirah = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = config.sefirah.nixosModules ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen
      ../../hardware-configuration.nix
      {
        networking.hostName = "sefirah";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.users.blackmage.imports = config.sefirah.homeModules;
      }
      # ThinkPad X1 7th gen (16 GB, iGPU-only) memory tuning for gaming.
      # Kept host-specific: other machines get their own sizing.
      # Mirrors Omarchy (zram-generator 90-omarchy.conf + 99-omarchy-sysctl.conf):
      # full-RAM zstd zram at priority 100 in front of the disk swap partition.
      {
        zramSwap = {
          enable = true;
          memoryPercent = 100; # 16G of 16G, like Omarchy/CachyOS zram-size = ram
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
      # ThinkPad thermal + power + scheduler tuning (Omarchy/CachyOS-inspired).
      ({ pkgs, ... }: {
        # No thermald: it refuses this platform on purpose
        # ("dytc_lapmode present: Thermald can't run on this platform") —
        # Lenovo's DYTC firmware owns thermal management here. No intel-lpmd
        # either: Whiskey Lake has no hybrid P/E cores.

        # Kyber I/O scheduler: 2ms read-latency target keeps interactive
        # reads flowing under write floods (Omarchy's 60-omarchy-io-scheduler).
        # Auto-switch power profile on AC plug/unplug (Omarchy's
        # omarchy-powerprofiles-set): performance on AC, balanced on battery.
        services.udev.extraRules = ''
          ACTION=="add|change", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", KERNEL=="nvme*|sd*|mmcblk*|vd*", ATTR{queue/scheduler}="kyber"
          SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
          SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance"
        '';
        systemd.services.powerprofiles-init = {
          description = "Set power profile from AC state at boot";
          wantedBy = [ "multi-user.target" ];
          wants = [ "power-profiles-daemon.service" ];
          after = [ "power-profiles-daemon.service" ];
          serviceConfig.Type = "oneshot";
          script = ''
            if [ "$(cat /sys/class/power_supply/AC/online 2>/dev/null)" = "1" ]; then
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set performance || ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
            else
              ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced
            fi
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
