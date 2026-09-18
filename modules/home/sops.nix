{ ... }:
{
  config.sefirah.homeModules = [
    {
      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        age.keyFile = "/home/blackmage/.config/sops/age/keys.txt";
        secrets.cachix-token = { };
      };
    }
  ];
}
