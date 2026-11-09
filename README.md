# Sefirah

<p align="center">
  <img src="assets/banner.png" alt="sefirah banner" width="100%">
</p>

---

## Overview

This is **sefirah** — a NixOS + Home Manager configuration forged for the **ThinkPad X1 Carbon 7th Gen (i7-8665U)**.

### Composition

| Realm             | Purpose               | Key Artifacts                                                                                                                                                                    |
| ----------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **🐚 Shell**      | The incantation layer | `zsh` + `fzf-tab`, `zsh-autosuggestions`, `fast-syntax-highlighting`, `you-should-use` · `atuin` (history) · `zoxide` (navigation) · `eza` (ls)                                  |
| **🖥 Terminal**   | The portal            | `foot` (Wayland native) · `kitty` (GPU-accelerated fallback)                                                                                                                     |
| **⌨️ Editor**     | The codex             | `nixCats-nvim` (modular Neovim) · `lazygit` · `lazydocker`                                                                                                                       |
| **🪟 Compositor** | The window weaver     | `niri` (scrollable-tiling) · KDL fragments + Stylix theming · `niri-only` guard                                                                                                  |
| **📊 Bar**        | The status sigil      | `waybar` (epoch theme) · `mako` (notifications) · `walker` (launcher)                                                                                                            |
| **🔐 Lock/Idle**  | The ward              | `hypridle` + `hyprlock` (Niri-agnostic)                                                                                                                                          |
| **🎮 Gaming**     | The arena             | `heroic` + `gamescope` · `steam` · `ananicy-cpp` (CachyOS rules)                                                                                                                 |
| **🎵 Media**      | The resonance         | `spotifast` (Spotify TUI) · `wiremix` (audio) · `playerctl`                                                                                                                      |
| **📁 Files**      | The archive           | `nautilus` · `yazi` (TUI) · `sushi` (preview)                                                                                                                                    |
| **🔧 Dev Tools**  | The forge             | `mise` (runtimes) · `nodejs`/`bun`/`rustc`/`cargo` · `gcc` · `lua`/`luarocks` · `python3` · `git` + `gh` · `httpie` · `jq` · `ripgrep` · `fd` · `bat` · `tealdeer` · `fastfetch` |
| **🌐 Browser**    | The scrying glass     | `brave` (forced scale) · `discord` (OpenASAR)                                                                                                                                    |
| **📦 Packaging**  | The alembic           | `nix-flatpak` · `mocktail` (macOS runner)                                                                                                                                        |
| **⚙️ System**     | The skeleton          | `power-profiles-daemon` (balanced) · `throttled` (Lenovo 80°C fix, RAPL, TCC offset) · `zram` (zstd, 100%) · `thinkpad_acpi` manual fan control                                  |
| **🔑 Secrets**    | The vault             | `sops` + `age`                                                                                                                                                                   |
| **🎨 Theming**    | The glamour           | `stylix` (base16/everforest/epoch) · `tela-icon-theme` · `gammastep` (nightlight)                                                                                                |

### 🖥 Host: **sefirah** (ThinkPad X1 Carbon 7th Gen)

| Spec      | Value                                                                                                                   |
| --------- | ----------------------------------------------------------------------------------------------------------------------- |
| CPU       | i7-8665U (Whiskey Lake, 4C/8T, 15W TDP, TjMax 100°C)                                                                    |
| Thermal   | Manual fan (`fan_control=1`, watchdog=0, keepalive@1s) · `throttled --sysfs --rapl --tcc-offset --tcc-offset-degrees=5` |
| Power     | RAPL PL1=12W / PL2=25W (re-applied every 60s) · `power-profiles-daemon` locked to `balanced`                            |
| Memory    | zram swap (zstd, 100%, swappiness=150) · zswap disabled                                                                 |
| Storage   | NVMe · `kyber` scheduler (udev rule)                                                                                    |
| SD Reader | **Blacklisted** (`rtsx_pci_sdmmc`, `mmc_block`) — saves ~2W                                                             |
| Suspend   | **Disabled** — lid/keys ignored, lock via `hypridle` only                                                               |

---

## 🗺 Structure — The Dendritic Map

> Auto-generated from flake configuration. Run `nix run .#update-readme` to regenerate.

<!-- BEGIN:AUTO-GENERATED -->
```mermaid
    flowchart TD
        %% ==========================================
        %% sefirah — dendritic NixOS + Home Manager
        %% Auto-generated from flake configuration
        %% ==========================================
    
    subgraph INPUTS["🔮 Flake Inputs"]
        direction TB
        IN_flake-parts["flake-parts\n(github:hercules-ci/flake-parts)"]
        IN_home-manager["home-manager\n(github:nix-community/home-manager)"]
        IN_import-tree["import-tree\n(github:denful/import-tree)"]
        IN_llm-agents["llm-agents\n(github:numtide/llm-agents.nix)"]
        IN_luvus["luvus\n(github:RizRiyz/luvus)"]
        IN_mocktail["mocktail\n(github:komaruworld/mocktail)"]
        IN_nix-flatpak["nix-flatpak\n(github:gmodena/nix-flatpak@v0.7.0)"]
        IN_nixCats["nixCats-nvim\n(github:BirdeeHub/nixCats-nvim)"]
        IN_nixos-hardware["nixos-hardware\n(github:NixOS/nixos-hardware)"]
        IN_nixpkgs["nixpkgs\n(github:NixOS/nixpkgs/nixos-unstable)"]
        IN_omp["oh-my-pi\n(github:can1357/oh-my-pi)"]
        IN_spotifast["spotifast\n(github:crmne/spotifast)"]
        IN_stylix["stylix\n(github:nix-community/stylix)"]
    end
    
    subgraph CORE["⚡ Core Composition"]
        direction TB
        CORE_FLAKE["flake.nix\nflake-parts.mkFlake"]
        CORE_MKSYS["lib/mkSystem.nix\nmkSystem { system, hostname, nixosModules, homeModules }"]
        CORE_IMPORT["import-tree ./modules\n(auto-discovers all modules)"]
    end
    
    subgraph SEFIRAH["config.sefirah"]
        direction TB
        SEF_NM["nixosModules\n(list of deferredModule)"]
        SEF_HM["homeModules\n(list of deferredModule)"]
    end
    
    subgraph NIXOS["modules/nixos/ (26 files)"]
        direction TB
        NM_audio["audio.nix"]
        NM_backup["backup.nix"]
        NM_base["base.nix"]
        NM_battery["battery.nix"]
        NM_boot["boot.nix"]
        NM_desktop["desktop.nix"]
        NM_firefox["firefox.nix"]
        NM_firewall["firewall.nix"]
        NM_firmware["firmware.nix"]
        NM_flatpak["flatpak.nix"]
        NM_fonts["fonts.nix"]
        NM_gaming["gaming.nix"]
        NM_graphics["graphics.nix"]
        NM_input["input.nix"]
        NM_nautilus["nautilus.nix"]
        NM_networking["networking.nix"]
        NM_niri["niri.nix"]
        NM_nix-ld["nix-ld.nix"]
        NM_plymouth["plymouth.nix"]
        NM_power["power.nix\n(power-profiles-daemon, no suspend/hibernate, logind lid=ignore)"]
        NM_printing["printing.nix"]
        NM_rustdesk["rustdesk.nix"]
        NM_steam["steam.nix"]
        NM_stylix["stylix.nix"]
        NM_thinkfan["thinkfan.nix\n(manual fan: fan_control=1, watchdog=0, keepalive@1s)"]
        NM_user["user.nix"]
    end
    
    subgraph HOME["modules/home/ (24 files)"]
        direction TB
        HM_base["base.nix\n(username, homedir, hm activation)"]
        HM_btop["btop.nix"]
        HM_dev-keys["dev-keys.nix"]
        HM_foot["foot.nix"]
        HM_gtk["gtk.nix"]
        HM_hypridle["hypridle.nix"]
        HM_hyprlock["hyprlock.nix"]
        HM_kitty["kitty.nix"]
        HM_luvus["luvus.nix"]
        HM_mako["mako.nix"]
        HM_mocktail["mocktail.nix"]
        HM_niri["niri.nix\n(KDL fragments + Stylix theming, niri-only guard)"]
        HM_omp["omp.nix"]
        HM_packages["packages.nix\n(home.packages list)"]
        HM_sefirah-lock["sefirah-lock.nix"]
        HM_services["services.nix\n(waybar user service)"]
        HM_shell["shell.nix\n(zsh + fzf-tab/autosuggestions/fast-syntax-highlighting/you-should-use, atuin, zoxide, eza)"]
        HM_stardew["stardew.nix"]
        HM_starship["starship.nix"]
        HM_tmux["tmux.nix"]
        HM_tofi["tofi.nix"]
        HM_waybar-style["waybar-style.nix"]
        HM_yazi["yazi.nix"]
        HM_zellij["zellij.nix"]
    end
    
    subgraph OVERLAYS["🎭 Overlays"]
        direction TB
        OV_9router["9router.nix"]
        OV_sefirah["sefirah.nix"]
        OV_thinkfan-tui["thinkfan-tui.nix\n(builds thinkfan-tui from source)"]
        OV_xwayland-satellite["xwayland-satellite.nix"]
    end
    
    subgraph PKGS["📦 Local Packages"]
        direction TB
        PKG_sefirah["pkgs/sefirah/sefirah/\n(ordinal, cmd_cards, main, cmd_draw, hour_lines,\n lock_layout, key_digest, planetary_hour, battery,\n card_of_day, cmd_transmute)"]
    end
    
    
        HW["hardware-configuration.nix\n(generated by nixos-generate-config)"]
    
        IN_flake-parts --> CORE_FLAKE
        IN_home-manager --> CORE_FLAKE
        IN_import-tree --> CORE_FLAKE
        IN_llm-agents --> CORE_FLAKE
        IN_luvus --> CORE_FLAKE
        IN_mocktail --> CORE_FLAKE
        IN_nix-flatpak --> CORE_FLAKE
        IN_nixCats --> CORE_FLAKE
        IN_nixos-hardware --> CORE_FLAKE
        IN_nixpkgs --> CORE_FLAKE
        IN_omp --> CORE_FLAKE
        IN_spotifast --> CORE_FLAKE
        IN_stylix --> CORE_FLAKE
        CORE_FLAKE --> CORE_IMPORT
        CORE_FLAKE --> CORE_MKSYS
        CORE_IMPORT --> SEF_NM
        CORE_IMPORT --> SEF_HM
        CORE_MKSYS --> NM_niri
        CORE_MKSYS --> HW
        SEF_NM --> NIXOS
        SEF_HM --> HOME
        NM_niri --> IN_nixos-hardware
        NM_niri --> HW
        SEF_NM --> OVERLAYS
        SEF_HM --> OVERLAYS
        CORE_MKSYS --> PKGS
        NM_niri --> PKGS
    
    classDef input fill:#1e1e2e,stroke:#cba6f7,color:#cdd6f4
    classDef core fill:#1e1e2e,stroke:#f9e2af,color:#cdd6f4
    classDef sefirah fill:#1e1e2e,stroke:#f5c2e7,color:#cdd6f4,stroke-width:2px
    classDef module fill:#1e1e2e,stroke:#a6e3a1,color:#cdd6f4
    classDef overlay fill:#1e1e2e,stroke:#fab387,color:#cdd6f4
    classDef pkg fill:#1e1e2e,stroke:#89b4fa,color:#cdd6f4
    classDef hw fill:#1e1e2e,stroke:#f38ba8,color:#cdd6f4
    
    class IN_flake-parts,IN_home-manager,IN_import-tree,IN_llm-agents,IN_luvus,IN_mocktail,IN_nix-flatpak,IN_nixCats,IN_nixos-hardware,IN_nixpkgs,IN_omp,IN_self,IN_spotifast,IN_stylix input
    class CORE_FLAKE,CORE_MKSYS,CORE_IMPORT core
    class SEF_NM,SEF_HM sefirah
    class NM_audio,NM_backup,NM_base,NM_battery,NM_boot,NM_desktop,NM_firefox,NM_firewall,NM_firmware,NM_flatpak,NM_fonts,NM_gaming,NM_graphics,NM_input,NM_nautilus,NM_networking,NM_niri,NM_nix-ld,NM_plymouth,NM_power,NM_printing,NM_rustdesk,NM_steam,NM_stylix,NM_thinkfan,NM_user module
    class HM_base,HM_btop,HM_dev-keys,HM_foot,HM_gtk,HM_hypridle,HM_hyprlock,HM_kitty,HM_luvus,HM_mako,HM_mocktail,HM_niri,HM_omp,HM_packages,HM_sefirah-lock,HM_services,HM_shell,HM_stardew,HM_starship,HM_tmux,HM_tofi,HM_waybar-style,HM_yazi,HM_zellij module
    class OV_9router,OV_sefirah,OV_thinkfan-tui,OV_xwayland-satellite overlay
    class PKG_sefirah pkg
    class HW hw
```
<!-- END:AUTO-GENERATED -->

---

## Patterns

### 1. Dendritic Module Composition (`config.sefirah.nixosModules` / `config.sefirah.homeModules`)

Every host declares **lists of deferred modules** — not inline config. The `mkSystem` function merges them:

```nix
# modules/options.nix
options.sefirah.nixosModules = lib.mkOption {
  type = lib.types.listOf lib.types.deferredModule;
  default = [ ];
};

# lib/mkSystem.nix
{ system, hostname, nixosModules ? [ ], homeModules ? [ ] }:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    { networking.hostName = hostname; }
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    { home-manager.users.blackmage.imports = homeModules; }
  ] ++ nixosModules;
}
```

**Why**: Hosts stay clean. Adding a module = one line in the host's list. No nesting hell.

### 2. `import-tree` Auto-Discovery

```nix
# flake.nix
outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
  imports = [ (inputs.import-tree ./modules) ];
};
```

Every `*.nix` under `modules/` becomes available as `config.sefirah.nixosModules` / `homeModules` — no manual `imports = [ ./foo.nix ./bar.nix ]`.

### 3. KDL Fragment Composition (Niri)

`modules/home/niri.nix` reads **individual `.kdl` fragments** and stitches them with **Stylix theme placeholders**:

```nix
themePlaceholders = {
  "@@BASE00@@" = hx tc.base00;
  "@@BASE08@@" = hx tc.base08;
  # ...
};
layout = subst themePlaceholders (builtins.readFile ./files/niri/layout.kdl);
```

Binds are concatenated into a single `binds {}` block (Niri forbids multiple).

### 4. Overlay Sigils (`overlays/`)

Four overlays, each a single-purpose transformation:

| Overlay | Purpose |
|---------|---------|
| `9router.nix` | Patches `9router` package |
| `sefirah.nix` | Core sefirah package tweaks |
| `thinkfan-tui.nix` | Builds `thinkfan-tui` from source (Cargo) |
| `xwayland-satellite.nix` | Patches XWayland satellite for Niri |

### 5. Host-Specific Thermal Stack (`modules/hosts/tx1c7.nix`)

```
throttled (Lenovo 80°C fix, RAPL, TCC offset -5°C)
    ↓ runs after
power-profiles-daemon (locked to balanced)
    ↓ reapplies every 60s
cpu-power-cap.service (PL1=12W, PL2=25W explicit)
    ↓ manual fan control
thinkpad_acpi (fan_control=1, watchdog=0, keepalive@1s level 0)
```

**No `thermald`** — broken on X1C7 (`dytc_lapmode` present). **No `auto-cpufreq`/`TLP`** — conflicts with PPD.

### 6. Declarative Scripts as Packages (`modules/home/packages.nix`)

```nix
(writeShellScriptBin "brightness" ''
  min=15; dev=intel_backlight; step=5
  case "$1" in up) sign=+ ;; down) sign=- ;; max) ... ;; min) ... ;; esac
  cur=$(brightnessctl -m -d "$dev" | cut -d, -f4 | tr -d %)
  next=$((cur $sign step)); [ "$next" -lt "$min" ] && next=$min
  exec brightnessctl -q -d "$dev" set "$next"%
'')
```

User-facing CLI tools (`brightness`, `waybar-reload`, `with-gamescope`, `niri-only`) are **first-class packages**, not ad-hoc scripts.

---

## Inspired By

| Source | What Was Taken |
|--------|----------------|
| **Omarchy** (basecamp/omarchy) | zram tuning, swappiness=150, `kyber` scheduler, `ananicy-cpp` CachyOS rules, power-profiles-daemon patterns |
| **CachyOS** | Kernel sysctl reclaim tuning, THP `always`, `ananicy-rules-cachyos` |
| **NixOS Hardware** | `lenovo-thinkpad-x1-7th-gen` module (firmware, sensors, acpi) |
| **erpalma/throttled** | Lenovo 80°C throttling fix, RAPL management, TCC offset, undervolt support |
| **stylix** (nix-community/stylix) | Base16 theming pipeline, wallpaper generation, cursor theming |
| **flake-parts** (hercules-ci/flake-parts) | Flake structure, per-system outputs, module system ergonomics |
| **import-tree** (denful/import-tree) | Auto-discovery of modules, zero-boilerplate composition |
| **niri** (YaLTeR/niri) | Scrollable tiling, KDL config, `niri validate` at build time |
| **nixCats-nvim** (BirdeeHub/nixCats-nvim) | Modular Neovim as a Nix package, category-based plugins |
| **thinkfan-tui** | TUI for manual fan control (thinkpad_acpi) |

---

## Acknowledgments

| Who | For What |
|-----|----------|
| **NixOS & nixpkgs contributors** | The foundation — pure, reproducible, composable |
| **Home Manager team** | User-space dotfile management as Nix modules |
| **flake-parts authors** | Making flakes ergonomic, not painful |
| **YaLTeR** | `niri` — the compositor that thinks different |
| **erpalma** | `throttled` — saved this X1C7 from 80°C throttling death |
| **stylix authors** | Theming that Just Works™ across GTK/Qt/Wayland |
| **Omarchy / CachyOS maintainers** | Battle-tested kernel/sysctl/power configs for laptops |
| **Numtide** | `llm-agents.nix` — AI tooling as first-class Nix citizens |
| **BirdeeHub** | `nixCats-nvim` — Neovim packaging done right |
| **denful** | `import-tree` — the module discovery I didn't know I needed |

---

## Quick Start

```bash
# Clone
git clone https://github.com/blackmage/sefirah ~/.config/nixpkgs
cd ~/.config/nixpkgs

# Build & switch (run as root)
sudo nixos-rebuild switch --flake .#sefirah

# Home Manager (user)
home-manager switch --flake .#blackmage@sefirah

# Regenerate structure diagram
nix run .#update-readme
```

> **Note**: Fan control requires reboot after first switch (kernel module params). The `fan-keepalive` service keeps fan at **level 0 (off)** until you change it via `thinkfan-tui`.

---

<p align="center">
  <sub>Generated by <code>nix run .#update-readme</code> · Diagram source in <code>modules/flake/diagrams.nix</code></sub>
</p>
