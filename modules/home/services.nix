{ ... }:
{
  config.sefirah.homeModules = [
    ({ lib, ... }: {
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
      # hypridle speaks Hyprland IPC (hyprctl DPMS/lock); never run it on Niri
      # where swayidle (see niri.nix) owns idle. XDG_CURRENT_DESKTOP=Hyprland
      # verified live in hyprland-uwsm sessions, so this is a no-op there.
      systemd.user.services.hypridle.Unit.ConditionEnvironment =
        lib.mkForce [ "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP=Hyprland" ];
    })
    ({ pkgs, ... }:
    let
      # One bar unit for both compositors: probe the running compositor at
      # startup and exec waybar with the matching config (default = Hyprland,
      # config-niri = Niri). Absolute paths: user-service PATH is minimal.
      waybar-session = pkgs.writeShellScriptBin "waybar-session" ''
        for _ in $(${pkgs.coreutils}/bin/seq 1 30); do
          if ${pkgs.hyprland}/bin/hyprctl monitors >/dev/null 2>&1; then
            exec ${pkgs.waybar}/bin/waybar
          elif ${pkgs.niri}/bin/niri msg outputs >/dev/null 2>&1; then
            exec ${pkgs.waybar}/bin/waybar -c "$HOME/.config/waybar/config-niri"
          fi
          ${pkgs.coreutils}/bin/sleep 0.5
        done
        exec ${pkgs.waybar}/bin/waybar
      '';
    in
    {
      systemd.user.services.waybar = {
        Unit = {
          Description = "Highly customizable Wayland bar";
          After = [ "graphical-session.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${waybar-session}/bin/waybar-session";
          ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    })
  ];
}
