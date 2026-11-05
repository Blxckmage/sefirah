{ inputs, ... }:
{
  # System-wide Flatpak packages. Updates manual for idempotent rebuilds.
  config.sefirah.nixosModules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    {
      services.flatpak.enable = true;
      services.flatpak.packages = [
        "org.vinegarhq.Sober"
        "com.spotify.Client"
      ];
    }
  ];
}
