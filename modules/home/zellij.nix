{ ... }:
{
  config.sefirah.homeModules = [
    {
      programs.zellij = {
        enable = true;
        settings.theme = "catppuccin-mocha";
      };
    }
  ];
}
