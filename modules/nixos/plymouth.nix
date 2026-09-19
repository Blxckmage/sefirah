{ ... }:
{
  config.sefirah.nixosModules = [
    {
      boot.plymouth.enable = true;
      boot.consoleLogLevel = 0;
      environment.etc."issue".text = "";
      environment.etc."issue.net".text = "";
      boot.kernelParams = [
        "quiet"
        "splash"
        "loglevel=3"
        "systemd.show_status=auto"
        "rd.udev.log_level=3"
      ];
    }
  ];
}
