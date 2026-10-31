{ inputs, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, lib, ... }: {
      home.packages = with pkgs; [
        impala
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
        claude-code
        (brave.override {
          commandLineArgs = "--force-device-scale-factor=1";
        })
        (discord.override {
          withOpenASAR = true;
          withVencord = true;
        })
        gcc
        rustc
        cargo
        lua
        luarocks
        git
        curl
        python3
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
        age
        sops
        cachix
        mcp-nixos
        walker
        lazydocker
        heroic
        (writeShellScriptBin "with-gamescope" ''
          exec gamescope -f -W 1920 -H 1080 -- "$@"
        '')
        motrix-next
        spotify
        (inputs.spotifast.packages.${pkgs.stdenv.hostPlatform.system}.spotifast.overrideAttrs {
          doCheck = false;
        })
        thinkfan-tui
        lm_sensors
        libreoffice
      ];
    })
  ];
}
