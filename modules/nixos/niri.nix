{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      # Session entries + portals; pick "Niri (UWSM)" at the login screen.
      programs.niri = {
        enable = true;
      };

      programs.uwsm = {
        enable = true;
        waylandCompositors.niri = {
          prettyName = "Niri";
          comment = "Niri compositor managed by UWSM";
          # niri-session is niri's own session wrapper (equiv. niri --session):
          # imports WAYLAND_DISPLAY etc. into systemd so user units like
          # swayidle/waybar start correctly under UWSM.
          binPath = "/run/current-system/sw/bin/niri-session";
        };
      };

      security.pam.services.swaylock = { };
    })
  ];
}
