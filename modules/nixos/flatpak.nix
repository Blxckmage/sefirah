{ inputs, ... }:
{
  # Sober (org.vinegarhq.Sober) is installed system-wide, so the NixOS module
  # is the right fit — no nested home-manager import (nix-flatpak#25).
  # Default flathub remote is added automatically; updates stay manual so
  # rebuilds are idempotent (Sober self-updates anyway).
  config.sefirah.nixosModules = [
    inputs.nix-flatpak.nixosModules.nix-flatpak
    {
      services.flatpak.enable = true;
      services.flatpak.packages = [
        "org.vinegarhq.Sober"
      ];
    }
  ];
}
