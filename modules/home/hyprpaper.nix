{ ... }:
{
  config.sefirah.homeModules = [
    {
      services.hyprpaper = {
        enable = true;
        settings = {
          splash = false;
          ipc = true;
          preload = [ "/home/blackmage/Pictures/wallpaper.jpg" ];
          wallpaper = [
            "eDP-1,/home/blackmage/Pictures/wallpaper.jpg"
            ",/home/blackmage/Pictures/wallpaper.jpg"
          ];
        };
      };
    }
    (
      { pkgs, ... }:
      let
        wallpaperDir = "/home/blackmage/Pictures/wallpapers";
        fallbackWallpaper = "/home/blackmage/Pictures/wallpaper.jpg";
        hyprpaper-random = pkgs.writeShellApplication {
          name = "hyprpaper-random";
          runtimeInputs = with pkgs; [
            hyprland
            findutils
            coreutils
            gnugrep
          ];
          text = ''
            set -euo pipefail
            DIR="${wallpaperDir}"
            FALLBACK="${fallbackWallpaper}"
            export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

            PIC=""
            if [ -d "$DIR" ]; then
              PIC="$(find "$DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \) -print0 2>/dev/null | shuf -zn1 | xargs -0 printf '%s\n' || true)"
            fi
            if [ -z "$PIC" ] && [ -f "$FALLBACK" ]; then
              PIC="$FALLBACK"
            fi
            if [ -z "$PIC" ]; then
              echo "hyprpaper-random: no wallpapers in $DIR and no fallback at $FALLBACK" >&2
              exit 1
            fi

            if [ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
              SOCK=""
              for _sock in "$XDG_RUNTIME_DIR"/hypr/*/.socket.sock; do
                [ -S "$_sock" ] || continue
                if [ -z "$SOCK" ] || [ "$_sock" -nt "$SOCK" ]; then
                  SOCK="$_sock"
                fi
              done
              if [ -n "$SOCK" ]; then
                HYPRLAND_INSTANCE_SIGNATURE="$(basename "$(dirname "$SOCK")")"
                export HYPRLAND_INSTANCE_SIGNATURE
              fi
            fi

            for _ in $(seq 1 60); do
              if hyprctl monitors >/dev/null 2>&1 && hyprctl hyprpaper listactive >/dev/null 2>&1; then
                break
              fi
              sleep 0.5
            done

            hyprctl hyprpaper wallpaper "eDP-1,$PIC" || hyprctl hyprpaper wallpaper ",$PIC"
          '';
        };
      in
      {
        home.packages = [ hyprpaper-random ];
      }
    )
  ];
}
