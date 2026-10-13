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

      # Local 9Router gateway as an omp custom provider. Models are pinned
      # statically: omp proxy discovery drops 9router's catalog entries.
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
            models:
              - id: kr/claude-sonnet-4.5
                name: Claude Sonnet 4.5 via 9Router
              - id: kr/claude-haiku-4.5
                name: Claude Haiku 4.5 via 9Router
              - id: kr/glm-5
                name: GLM 5 via 9Router
              - id: kr/deepseek-3.2
                name: DeepSeek 3.2 via 9Router
              - id: kr/qwen3-coder-next
                name: Qwen3 Coder via 9Router
              - id: kr/minimax-m2.5
                name: MiniMax M2.5 via 9Router
              - id: openrouter/nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free
                name: Nemotron Nano (free) via 9Router
              - id: cf/@cf/meta/llama-3.3-70b-instruct-fp8-fast
                name: Llama 3.3 70B (free) via 9Router
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
