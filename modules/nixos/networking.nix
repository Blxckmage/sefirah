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

      # APKPure's metadata host is DNS-poisoned by the ISP blockpage.
      # shortcut: pinned IPs; update if Cloudflare rotates them.
      networking.hosts = {
        "104.20.24.85" = [ "api.pureapk.com" ];
        "172.66.150.6" = [ "api.pureapk.com" ];
      };

      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
    }
  ];
}
