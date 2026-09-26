{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      # Scrollable-tiling compositor alongside Hyprland (which stays the
      # default session in desktop.nix). Enabling this adds the stock
      # "Niri" SDDM entry, xdg-desktop-portal-gnome + gnome-keyring and the
      # portal config Niri expects (gnome + gtk). Pick "Niri (UWSM)" at SDDM
      # to get the UWSM-managed session below, consistent with hyprland-uwsm.
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
