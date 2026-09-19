{ ... }:
{
  config.sefirah.nixosModules = [
    {
      networking.firewall.allowedTCPPorts = [ 57621 ];
      networking.firewall.allowedUDPPorts = [ 5353 ];
    }
  ];
}
