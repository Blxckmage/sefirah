{ inputs, ... }:
{
  config.sefirah.homeModules = [
    inputs.omp.homeManagerModules.default
    ({ pkgs, lib, ... }:
      let
        ompModelsFile = pkgs.writeText "omp-models.yml" ''
          providers:
            ninerouter:
              baseUrl: http://localhost:20128/v1
              api: openai-completions
              apiKey: NINEROUTER_KEY
              discovery:
                type: openai-models-list
                timeoutMs: 5000
              models:
                - id: best
                  name: Best (Combo)
                - id: think
                  name: Think (Combo)
                - id: long-context
                  name: Long Context (Combo)
                - id: fast
                  name: Fast (Combo)
        '';
      in
      {
      programs.omp = {
        enable = true;
        # Full wizard state declared for idempotent activation.
        settings = {
          startup.quiet = true;
          setupVersion = 2;
          symbolPreset = "nerd";
          composer.shape = "pi";
          theme.dark = "dark-forest";
          modelRoles.default = "ninerouter/best";
        };
      };

      home.packages = [ pkgs._9router ];

      # 9Router custom provider. Writable file via activation (not home.file)
      # for setup wizard persistence. apiKey resolves NINEROUTER_KEY env var.
      home.activation.ompModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.omp/agent"
        install -m 600 ${ompModelsFile} "$HOME/.omp/agent/models.yml"
      '';

      # --skip-update: updates via rebuilds. --host 127.0.0.1: local-only.
      systemd.user.services."9router" = {
        Unit = {
          Description = "9Router local AI gateway";
          After = [ "network-online.target" ];
          Wants = [ "network-online.target" ];
        };
        Service = {
          ExecStart = "${pkgs._9router}/bin/9router --port 20128 --host 127.0.0.1 --no-browser --skip-update";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install.WantedBy = [ "default.target" ];
      };

      home.sessionVariables = {
        ANTHROPIC_BASE_URL = "http://localhost:20128/v1";
      };

      programs.zsh.initContent = ''
        if command -v omp &>/dev/null; then eval "$(omp completions zsh)"; fi

        # 9router gateway key from sqlite, runtime-resolved.
        if [ -z "$NINEROUTER_KEY" ]; then
          _nine_key=$(python3 -c "import sqlite3; print(sqlite3.connect('file://$HOME/.9router/db/data.sqlite?mode=ro', uri=True).execute('select key from apiKeys where isActive = 1 limit 1').fetchone()[0])" 2>/dev/null)
          [ -n "$_nine_key" ] && export NINEROUTER_KEY="$_nine_key"
          unset _nine_key
        fi
        if [ -n "$NINEROUTER_KEY" ]; then
          [ -z "$ANTHROPIC_AUTH_TOKEN" ] && export ANTHROPIC_AUTH_TOKEN="$NINEROUTER_KEY"
          [ -z "$ANTHROPIC_API_KEY" ] && export ANTHROPIC_API_KEY="$NINEROUTER_KEY"
        fi
      '';
    })
  ];
}
