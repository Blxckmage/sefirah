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
        # Declare the full wizard-completed state so the activation copy is
        # idempotent: previously only startup.quiet was declared, so every
        # switch rewrote config.yml and wiped setupVersion/modelRoles/theme,
        # sending omp back to setup. Matches live ~/.omp/agent/config.yml.
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

      # Local 9Router gateway as an omp custom provider. Managed as a
      # writable regular file via activation (same pattern as upstream
      # programs.omp.settings), NOT home.file: a store symlink is read-only,
      # so the setup wizard / discovery merge cannot persist and every launch
      # revisits setup. Content mirrors the working live file: 4 static
      # combos + openai-models-list discovery (verified: `omp models
      # ninerouter` merges to 32 entries). apiKey resolves as env var
      # NINEROUTER_KEY first, literal otherwise — so
      # `export NINEROUTER_KEY="sk-..."` (dashboard key) wins and no secret
      # lands in the Nix store. Keyless local installs accept anything.
      # Verify with: omp models ninerouter
      home.activation.ompModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "$HOME/.omp/agent"
        install -m 600 ${ompModelsFile} "$HOME/.omp/agent/models.yml"
      '';

      # --skip-update: Nix store is immutable, updates come via rebuilds.
      # --host 127.0.0.1: local-only bind, no LAN exposure for the gateway.
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

      # Claude Code via the gateway: endpoint is static, the key resolves
      # at runtime (see initContent) so no secret lands in the store.
      home.sessionVariables = {
        ANTHROPIC_BASE_URL = "http://localhost:20128/v1";
      };

      programs.zsh.initContent = ''
        if command -v omp &>/dev/null; then eval "$(omp completions zsh)"; fi

        # 9router gateway key (dashboard Default Key), resolved at runtime so
        # no secret lands in the store. An exported NINEROUTER_KEY wins.
        if [ -z "$NINEROUTER_KEY" ]; then
          _nine_key=$(python3 -c "import sqlite3; print(sqlite3.connect('file://$HOME/.9router/db/data.sqlite?mode=ro', uri=True).execute('select key from apiKeys where isActive = 1 limit 1').fetchone()[0])" 2>/dev/null)
          [ -n "$_nine_key" ] && export NINEROUTER_KEY="$_nine_key"
          unset _nine_key
        fi
        if [ -n "$NINEROUTER_KEY" ] && [ -z "$ANTHROPIC_AUTH_TOKEN" ]; then
          export ANTHROPIC_AUTH_TOKEN="$NINEROUTER_KEY"
        fi
      '';
    })
  ];
}
