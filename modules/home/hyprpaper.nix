{ ... }:
{
  config.sefirah.homeModules = [
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          preload = [ "/home/blackmage/Pictures/wallpaper.jpg" ];
          wallpaper = [
            "eDP-1,/home/blackmage/Pictures/wallpaper.jpg"
            ",/home/blackmage/Pictures/wallpaper.jpg"
          ];
        };
      };
    }
    ({ lib, ... }: {
      systemd.user.services.hyprpaper.Unit.After = lib.mkForce [ "default.target" ];
      systemd.user.services.hyprpaper.Unit.PartOf = lib.mkForce [ "default.target" ];
      systemd.user.services.hyprpaper.Install.WantedBy = lib.mkForce [ "default.target" ];
    })
  ];
}
