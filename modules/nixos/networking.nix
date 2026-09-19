{ ... }:
{
  config.sefirah.nixosModules = [
    {
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.backend = "iwd";
      environment.etc."NetworkManager/conf.d/20-iwd-no-autoconnect.conf".text = ''
        [device-wifi]
        match-device = type:wifi
        wifi.iwd.autoconnect = false
      '';
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
    }
  ];
}
