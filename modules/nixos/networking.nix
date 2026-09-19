{ ... }:
{
  config.sefirah.nixosModules = [
    {
      networking.networkmanager.enable = true;
      networking.networkmanager.wifi.backend = "iwd";
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
    }
  ];
}
