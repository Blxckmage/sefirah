{ lib, ... }:
{
  config.sefirah.nixosModules = [
    {
      networking.networkmanager.enable = true;
      networking.networkmanager.unmanaged = [ "type:wifi" ];

      networking.wireless.enable = lib.mkForce false;
      networking.wireless.iwd.enable = true;
      networking.wireless.iwd.settings = {
        General.EnableNetworkConfiguration = true;
        Settings.AutoConnect = true;
      };

      services.resolved.enable = true;
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
    }
  ];
}
