{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      home.packages = [ pkgs.swaylock-effects ];

      xdg.configFile."swaylock/config".text = ''
        image=${../theme/wallpapers/epoch-umber-lock.png}
        scaling=fill
        font=PxPlus IBM VGA 8x16
        font-size=16
        clock
        timestr=%H:%M
        datestr=%a %d %b
        indicator
        indicator-caps-lock
        show-failed-attempts
        show-keyboard-layout
        indicator-radius=80
        indicator-thickness=2
        inside-color=0d0b08cc
        inside-clear-color=0d0b08cc
        inside-ver-color=0d0b08cc
        inside-wrong-color=0d0b08cc
        inside-caps-lock-color=0d0b08cc
        ring-color=d49a3aff
        ring-clear-color=d49a3aff
        ring-ver-color=8f9a5aff
        ring-wrong-color=d25f42ff
        ring-caps-lock-color=d25f42ff
        line-color=3a3126ff
        line-clear-color=3a3126ff
        line-ver-color=8f9a5aff
        line-wrong-color=d25f42ff
        line-caps-lock-color=d25f42ff
        separator-color=3a3126ff
        text-color=e3d6b8ff
        text-clear-color=e3d6b8ff
        text-ver-color=8f9a5aff
        text-wrong-color=d25f42ff
        text-caps-lock-color=d25f42ff
        key-hl-color=d49a3aff
        bs-hl-color=d25f42ff
        caps-lock-key-hl-color=d25f42ff
        caps-lock-bs-hl-color=d25f42ff
        layout-bg-color=0d0b08cc
        layout-border-color=3a3126ff
        layout-text-color=cfc1a3ff
      '';
    })
  ];
}
