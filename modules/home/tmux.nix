{ ... }:
{
  # Ports ~/.config/tmux/tmux.conf (unmanaged) to programs.tmux.
  # - sessionx comes from nixpkgs; tmux-menus (jaclu) is not packaged, so it
  #   is built with mkTmuxPlugin pinned to v2.4.1. tpm itself goes away.
  # - HM manages the XDG path, so reload targets it explicitly.
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      programs.tmux = {
        enable = true;
        prefix = "C-a";
        baseIndex = 1;
        historyLimit = 50000;
        escapeTime = 0;
        keyMode = "vi";
        mouse = true;
        plugins = with pkgs.tmuxPlugins; [
          tmux-sessionx
          (mkTmuxPlugin {
            pluginName = "tmux-menus";
            version = "2.4.1";
            rtpFilePath = "menus.tmux";
            src = pkgs.fetchFromGitHub {
              owner = "jaclu";
              repo = "tmux-menus";
              rev = "v2.4.1";
              hash = "sha256-WtTwd8M8dcEikKe9JpYPDW8iqO0VuIjGBaO9CPtOTec=";
            };
          })
        ];
        extraConfig = ''
          unbind C-b
          bind C-a send-prefix

          # Reload config
          bind C-r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded"

          setw -g pane-base-index 1
          set -g renumber-windows on
          set -g default-terminal "tmux-256color"
          set -ag terminal-overrides ",*:RGB"
          set -g focus-events on
          set -g set-clipboard on
          set -g allow-passthrough on
          setw -g aggressive-resize on
          set -g detach-on-destroy off

          # Copy mode
          bind -T copy-mode-vi v send -X begin-selection
          bind -T copy-mode-vi y send -X copy-selection-and-cancel

          # Splits in current path
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # Vim-style pane navigation (k is kill-window below, not pane-up)
          bind h select-pane -L
          bind j select-pane -D
          bind l select-pane -R

          bind r command-prompt -I "#W" "rename-window -- '%%'"
          bind c new-window -c "#{pane_current_path}"
          bind k kill-window

          bind R command-prompt -I "#S" "rename-session -- '%%'"
          bind C new-session -c "#{pane_current_path}"
          bind K kill-session
          bind P switch-client -p
          bind N switch-client -n

          # Appearance
          set -g status-position top
          set -g status-interval 5
          set -g status-left-length 30
          set -g status-right-length 50
          set -g window-status-separator ""
          set -gw automatic-rename on
          # set -gw automatic-rename-format '#{b:pane_current_path}'

          set -g status-style "bg=default,fg=brightwhite"
          set -g status-left "#[fg=black,bg=white,bold] #S #[bg=default] "
          set -g status-right "#[fg=white]#{?pane_in_mode,COPY ,}#{?client_prefix,PREFIX ,}#{?window_zoomed_flag,ZOOM ,}#[fg=white]#h "
          set -g window-status-format "#[fg=white] #I:#W "
          set -g window-status-current-format "#[fg=brightwhite,bold] #I:#W "
          set -g pane-border-style "fg=brightblack"
          set -g pane-active-border-style "fg=white"
          set -g message-style "bg=default,fg=white"
          set -g message-command-style "bg=default,fg=white"
          set -g mode-style "bg=white,fg=black"
          setw -g clock-mode-colour white
        '';
      };
    })
  ];
}
