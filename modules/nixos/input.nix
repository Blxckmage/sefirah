{ ... }:
{
  config.sefirah.nixosModules = [
    {
      services.libinput.enable = true;
      services.udev.extraRules = ''
        ACTION=="add|change", ATTRS{name}=="AT Translated Set 2 keyboard", ENV{ID_INPUT_KEYBOARD}=="1", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
    }
  ];
}
