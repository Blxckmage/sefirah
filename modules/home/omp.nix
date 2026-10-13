{ inputs, ... }:
{
  config.sefirah.homeModules = [
    inputs.omp.homeManagerModules.default
    ({ pkgs, ... }: {
      programs.omp = {
        enable = true;
        settings.startup.quiet = true;
      };

      home.packages = [ pkgs._9router ];

      # apiKey resolves as env var NINEROUTER_KEY first, literal otherwise —
      # so `export NINEROUTER_KEY="sk-..."` (dashboard key) wins and no
      # secret lands in the Nix store. Keyless local installs accept anything.
      # Verify with: omp models ninerouter
      home.file.".omp/agent/models.yml".text = ''
        providers:
          ninerouter:
            baseUrl: http://localhost:20128/v1
            api: openai-completions
            apiKey: NINEROUTER_KEY
      '';

      # --skip-update: Nix store is immutable, updates come via rebuilds.
      systemd.user.services."9router" = {
        Unit = {
          Description = "9Router local AI gateway";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          ExecStart = "${pkgs._9router}/bin/9router --port 20128 --no-browser --skip-update";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = [ "default.target" ];
      };

      programs.zsh.initContent = ''
        if command -v omp &>/dev/null; then eval "$(omp completions zsh)"; fi
      '';
    })
  ];
}
