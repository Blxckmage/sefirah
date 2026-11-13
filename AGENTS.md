# AGENTS.md

NixOS + Home Manager flake for the ThinkPad X1 Carbon 7th gen. One host (`sefirah`) today.

## Flow

`flake.nix` → `import-tree ./modules` (every `*.nix` under `modules/` is a flake-parts module) → `modules/hosts/tx1c7.nix` builds `nixosConfigurations.sefirah` via `lib/mkSystem.nix`.

Feature modules copy `modules/template.nix`: options first, then self-register with `config.sefirah.nixosModules = [ ... ]` (or `homeModules`). `modules/hosts/tx1c7.nix` is the single place those lists reach `mkSystem`.

## Verify

- `sudo nixos-rebuild switch --flake .#sefirah`, or `nh os switch .`
- There are no `checks`, dev shells or formatter: the build is the test. Cheap eval gate: `nix eval .#nixosConfigurations.sefirah.config.system.build.toplevel.drvPath`

## Conventions

- Commits pass `hooks/commit-msg` (`git config core.hooksPath hooks`): `type(area): imperative`, areas listed in the hook.
- Host-specific config stays in `modules/hosts/tx1c7.nix`; overlays are imported in `modules/nixos/base.nix`, except `xwayland-satellite.nix` in `modules/nixos/steam.nix`.
- `nixpkgs` is pinned to a commit that still has `brave` — read the comment in `flake.nix` before bumping it.
