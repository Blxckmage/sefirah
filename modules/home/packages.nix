{ inputs, ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = with pkgs; [
        neovim
        vim
        impala
        tmux
        inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
        (brave.override {
          commandLineArgs = "--force-device-scale-factor=1";
        })
        discord
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
        starship
        fzf
        eza
        zoxide
        atuin
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
        hyprlock
        cliphist
        nautilus
        sushi
        tela-icon-theme
        waybar
        hyprpaper
        mako
        hypridle
        hyprsunset
        qalculate-gtk
        yazi
        zellij
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
        zsh-fzf-tab
        zsh-you-should-use
        zsh-autosuggestions
        zsh-fast-syntax-highlighting
        heroic
        (writeShellScriptBin "with-gamescope" ''
          exec gamescope -f -W 1920 -H 1080 -- "$@"
        '')
        motrix-next
        spotify
        thinkfan-tui
        lm_sensors
      ];
    })
  ];
}
