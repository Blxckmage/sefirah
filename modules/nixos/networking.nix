{ ... }:
{
  config.sefirah.nixosModules = [
    {
      networking.networkmanager.enable = true;
      time.timeZone = "Asia/Jakarta";
      i18n.defaultLocale = "en_US.UTF-8";
    }
  ];
}
