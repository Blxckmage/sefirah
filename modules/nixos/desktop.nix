{ config, pkgs, ... }:
{
  config.sefirah.nixosModules = [
    ({ config, pkgs, ... }: {
      services.xserver.enable = true;
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      services.xserver.displayManager.lightdm.enable = false;
      services.xserver.desktopManager.xfce.enable = true;

      # SDDM removed: greeter had no working cursor (weston) and no fix
      # stuck. greetd + tuigreet is keyboard-driven: no mouse needed, ever.
      services.displayManager.sddm.enable = false;
      services.displayManager.defaultSession = "niri-uwsm";

      services.greetd = {
        enable = true;
        # TUI greeter: silence boot-log spam on the login screen.
        useTextGreeter = true;
        settings.default_session.command =
          "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session "
          + "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions "
          + "--xsessions ${config.services.displayManager.sessionData.desktops}/share/xsessions "
          + "--user-menu --asterisks --power-shutdown 'systemctl poweroff' --power-reboot 'systemctl reboot'";
      };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    })
  ];
}
