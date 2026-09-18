{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      services.xserver.enable = true;
      services.xserver.displayManager.lightdm.enable = true;
      services.xserver.desktopManager.xfce.enable = true;
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };

      security.pam.services.hyprlock = { };

      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
      };
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    })
  ];
}
