{ ... }:
{
  # HM-ified shell stack. Ports modules/home/files/zsh/* (retired) to native
  # Home Manager modules: tool inits (starship/zoxide/fzf/atuin) come from
  # their programs.* modules instead of hand-rolled eval lines, and the four
  # zsh plugins resolve from the nix store instead of profile probing with a
  # git-clone fallback (which is also why fzf-tab actually loads now).
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
          # Extra shell behavior (HM covers history file/size/sharing above).
          setopt inc_append_history autocd no_beep interactivecomments
          unsetopt nomatch

          # ~/.local/bin first if present.
          if [ -d "$HOME/.local/bin" ]; then
            export PATH="$HOME/.local/bin:$PATH"
          fi

          # Classic dirs appended last — nix profiles keep priority.
          for d in /usr/local/bin /usr/bin; do
            case ":$PATH:" in *":$d:"*) ;; *) [ -d "$d" ] && export PATH="$PATH:$d" ;; esac
          done

          # Tool install prefixes (bins are empty today; PATH entries get
          # added back if anything is ever installed under them).
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

          # Readline-style bindings (from files/zsh/inputrc).
          bindkey "^[[A" history-beginning-search-backward
          bindkey "^[[B" history-beginning-search-forward
          bindkey '\e[C' forward-char
          bindkey '\e[D' backward-char
          autoload edit-command-line
          zle -N edit-command-line
          bindkey "^X^E" edit-command-line

          # Technicolor dreams.
          force_color_prompt=yes
          color_prompt=yes
          autoload -Uz add-zsh-hook

          # gpg pinentry-curses needs the calling TTY; programs.gpg already
          # exports GPG_TTY=$TTY below, so no hand-rolled line here.

          # mise lazy activation (mise itself comes from home.packages).
          if command -v mise &> /dev/null; then
            mise() {
              unfunction mise
              eval "$(command mise activate zsh)"
              mise "$@"
            }
          fi

          # cargo (guarded — missing until rustup/cargo provides ~/.cargo/env).
          [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

          # zoxide-backed cd: dirs pass through, anything else goes to z.
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

          # Yazi change directory.
          function y() {
            local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
            yazi "$@" --cwd-file="$tmp"
            IFS= read -r -d "" cwd < "$tmp"
            [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
            rm -f -- "$tmp"
          }

          # File manager in current directory.
          function n() {
            local dir="''${1:-$PWD}"
            if command -v thunar &>/dev/null; then
              (thunar "$dir" &> /dev/null &)
            else
              (nautilus "$dir" &> /dev/null &)
            fi
          }

          # Copy dir path / file path.
          cfp() {
            readlink -f "$1" | wl-copy
          }

          # Open files with xdg-open in the background.
          open() (
            xdg-open "$@" >/dev/null 2>&1 &
          )
        '';
      };

      # Replaces the hand-rolled `eval "$(atuin init zsh)"` + ^R bind.
      # Existing ~/.config/atuin/config.toml is template defaults, so the
      # generated config is equivalent (hm-bak backup still applies).
      programs.atuin.enable = true;

      # Provides `z` for the zd wrapper above.
      programs.zoxide.enable = true;

      # Replaces the manual `fzf --zsh` eval + Arch fallback paths.
      # Atuin keeps Ctrl-R (as before, where it was sourced last).
      programs.fzf = {
        enable = true;
        historyWidget.bash.command = "";
        historyWidget.zsh.command = "";
      };

      # Binary via module, aliases stay hand-rolled (exact eza flags kept).
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
