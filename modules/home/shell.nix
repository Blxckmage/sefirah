{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      programs.zsh = {
        enable = true;
        # HM completion runs compinit on every shell; keep it off and run a
        # cached init below instead.
        enableCompletion = false;
        history = {
          size = 50000;
          save = 50000;
          share = true;
          ignoreAllDups = true;
          extended = true;
        };
        shellAliases = {
          ls = "eza -lh --group-directories-first --icons=auto";
          lsa = "ls -a";
          lt = "eza --tree --level=2 --long --icons --git";
          lta = "lt -a";
          ff = "fzf --preview 'bat --style=numbers --color=always {}'";
          lg = "lazygit";
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          cp = "cp -i";
          mv = "mv -i";
          rm = "rm -i";
          rmt = "gio trash";
          zel = "zellij";
          gi = "git init";
          gss = "git status -s";
          c = "clear";
          o = "opencode";
          d = "lazydocker";
          cdp = "pwd | wl-copy";
          ports = "lsof -i -P -n | grep LISTEN";
        };
        plugins = [
          {
            name = "fzf-tab";
            src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
            file = "fzf-tab.plugin.zsh";
          }
          {
            name = "zsh-autosuggestions";
            src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
            file = "zsh-autosuggestions.zsh";
          }
          {
            name = "fast-syntax-highlighting";
            src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
            file = "fast-syntax-highlighting.plugin.zsh";
          }
          {
            name = "zsh-you-should-use";
            src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use";
            file = "you-should-use.plugin.zsh";
          }
        ];
        initContent = ''
          setopt inc_append_history autocd no_beep interactivecomments
          unsetopt nomatch

          if [ -d "$HOME/.local/bin" ]; then
            export PATH="$HOME/.local/bin:$PATH"
          fi

          # Classic dirs appended last — nix profiles keep priority.
          for d in /usr/local/bin /usr/bin; do
            case ":$PATH:" in *":$d:"*) ;; *) [ -d "$d" ] && export PATH="$PATH:$d" ;; esac
          done

          export BUN_INSTALL="$HOME/.bun"
          export NPM_CONFIG_PREFIX="$HOME/.npm-global"

          # Completion, cached. NOTE: this used to be a 24h-freshness guard
          # (~/.zcompdump(#qN.mh+24)), but that qualifier needs extendedglob
          # (off here), so [[ -n ... ]] was always true and every shell ran a
          # full ~1.5s compinit. Unconditional -C is ~20ms.
          autoload -Uz compinit
          compinit -C -d ~/.zcompdump
          zstyle ':completion:*' menu select
          bindkey -e

          bindkey "^[[A" history-beginning-search-backward
          bindkey "^[[B" history-beginning-search-forward
          bindkey '\e[C' forward-char
          bindkey '\e[D' backward-char
          autoload edit-command-line
          zle -N edit-command-line
          bindkey "^X^E" edit-command-line

          force_color_prompt=yes
          color_prompt=yes
          autoload -Uz add-zsh-hook

          if command -v mise &> /dev/null; then
            mise() {
              unfunction mise
              eval "$(command mise activate zsh)"
              mise "$@"
            }
          fi

          # cargo (guarded — missing until rustup/cargo provides ~/.cargo/env).
          [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

          if command -v zoxide &> /dev/null; then
            alias cd="zd"
            zd() {
              if (( $# == 0 )); then
                builtin cd ~ || return
              elif [[ -d $1 ]]; then
                builtin cd "$1" || return
              else
                if ! z "$@"; then
                  echo "Error: Directory not found"
                  return 1
                fi

                printf "\U000F17A9 "
                pwd
              fi
            }
          fi

          function y() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            yazi "$@" --cwd-file="$tmp"
            IFS= read -r -d "" cwd < "$tmp"
            [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
            rm -f -- "$tmp"
          }

          function n() {
            local dir="''${1:-$PWD}"
            if command -v thunar &>/dev/null; then
              (thunar "$dir" &> /dev/null &)
            else
              (nautilus "$dir" &> /dev/null &)
            fi
          }

          cfp() {
            readlink -f "$1" | wl-copy
          }

          open() (
            xdg-open "$@" >/dev/null 2>&1 &
          )
        '';
      };

      # Up-arrow stays native history (history-beginning-search-backward
      # bound below); Atuin opens on Ctrl-R only, in both bash and zsh.
      programs.atuin = {
        enable = true;
        flags = [ "--disable-up-arrow" ];
      };

      # Provides `z` for the zd wrapper above.
      programs.zoxide.enable = true;

      # fzf keeps its default Tab-completion binds; history search on
      # Ctrl-R stays with Atuin (see programs.atuin.flags above).
      programs.fzf = {
        enable = true;
        historyWidget.bash.command = "";
        historyWidget.zsh.command = "";
      };

      programs.eza = {
        enable = true;
        enableZshIntegration = false;
      };

      home.sessionVariables = {
        EDITOR = "nvim";
        SUDO_EDITOR = "nvim";
        BAT_THEME = "ansi";
      };
    })
  ];
}
