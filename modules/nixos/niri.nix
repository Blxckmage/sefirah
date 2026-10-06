{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      # Niri is the only compositor (and the default login session):
      # this enables the "Niri" and "Niri (UWSM)" session entries,
      # xdg-desktop-portal-gnome + gnome-keyring and the portal config
      # Niri expects (gnome + gtk). Pick "Niri (UWSM)" at greetd/tuigreet
      # to get the UWSM-managed session below.
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
