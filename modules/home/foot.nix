{ ... }:
{
  config.sefirah.homeModules = [
    {
      xdg.configFile."foot/foot.ini".text = ''
        font=CaskaydiaMono Nerd Font:size=11

        [colors]
        background=272e33
        foreground=d3c6aa
        regular0=272e33
        regular1=7fbbb3
        regular2=83c092
        regular3=dbbc7f
        regular4=a7c080
        regular5=e67e80
        regular6=e69875
        regular7=d3c6aa
        bright0=859289
        bright1=7fbbb3
        bright2=83c092
        bright3=dbbc7f
        bright4=a7c080
        bright5=e67e80
        bright6=e69875
        bright7=fdf6e3
      '';
    }
  ];
}
