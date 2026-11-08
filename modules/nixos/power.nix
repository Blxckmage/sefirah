{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.power-profiles-daemon.enable = true;

      # Never suspend/hibernate; locking stays as-is (hypridle + lid).
      systemd.sleep.settings.Sleep = {
        AllowSuspend = "no";
        AllowHibernation = "no";
        AllowHybridSleep = "no";
        AllowSuspendThenHibernate = "no";
      };

      services.logind.settings.Login = {
        # Niri doesn't answer logind's Lock request, so "lock" would be a no-op.
        HandleLidSwitch = "ignore";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
        HandleSuspendKey = "ignore";
        HandleHibernateKey = "ignore";
        IdleAction = "ignore";
      };
    }
  ];
}
