{ ... }:
{
  config.sefirah.nixosModules = [
    ({ pkgs, ... }: {
      environment.systemPackages = [ pkgs.rustdesk-flutter ];

      # Lets RustDesk inject input while controlling this machine.
      hardware.uinput.enable = true;
      users.users.blackmage.extraGroups = [ "uinput" ];
    })
  ];
}
