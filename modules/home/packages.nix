{ inputs, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, lib, ... }: {
      home.packages = with pkgs; [
        impala
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code
        (brave.override {
          commandLineArgs = "--force-device-scale-factor=1";
        })
        (discord.override {
          withOpenASAR = true;
        })
        gcc
        rustc
        cargo
        lua
        luarocks
        git
        curl
        python3
        sefirah
        nodejs
        bun
        mise
        bat
        fd
        lsof
        wl-clipboard
        libnotify
        brightnessctl
        playerctl
        wiremix
        grim
        slurp
        satty
        cliphist
        nautilus
        sushi
        tela-icon-theme
        waybar
        mako
        qalculate-gtk
        lazygit
        gh
        httpie
        tealdeer
        fastfetch
        ripgrep
        jq
        tree
        p7zip
        unzip
        unrar
        (writeShellScriptBin "waybar-reload" ''
          systemctl --user restart waybar.service
        '')
        (writeShellScriptBin "brightness" ''
          min=15
          dev=intel_backlight
          bc=${brightnessctl}/bin/brightnessctl
          step=5
          case "$1" in
            up) sign=+ ;;
            down) sign=- ;;
            up-fine) sign=+; step=1 ;;
            down-fine) sign=-; step=1 ;;
            max) exec "$bc" -q -d "$dev" set 100% ;;
            min) exec "$bc" -q -d "$dev" set "$min"% ;;
            *) echo "usage: brightness up|down|up-fine|down-fine|max|min" >&2; exit 2 ;;
          esac
          cur=$("$bc" -m -d "$dev" | cut -d, -f4 | tr -d %) || exit 1
          next=$((cur $sign step))
          [ "$next" -lt "$min" ] && next=$min
          [ "$next" -gt 100 ] && next=100
          exec "$bc" -q -d "$dev" set "$next"%
        '')
        age
        sops
        mcp-nixos
        walker
        lazydocker
        heroic
        (writeShellScriptBin "with-gamescope" ''
          exec gamescope -f -W 1920 -H 1080 -- "$@"
        '')
        motrix-next
        (inputs.spotifast.packages.${pkgs.stdenv.hostPlatform.system}.spotifast.overrideAttrs {
          doCheck = false;
        })
        thinkfan-tui
        lm_sensors
        typst
        libreoffice
      ];
    })
  ];
}
