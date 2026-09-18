{ ... }:
{
  config.sefirah.homeModules = [
    {
      home.file.".config/MangoHud/MangoHud.conf".text = ''
        fps
        cpu_temp
        gpu_temp
        ram
        vram
        position=top-left
        toggle_hud=Shift_L+F12
      '';
    }
  ];
}
