{ ... }:
{
  config.sefirah.homeModules = [
    {
      programs.yazi = {
        enable = true;
        # Shell `y` wrapper lives in shell.nix (NUL-safe cd); HM's copy would
        # redefine it.
        enableZshIntegration = false;
        settings = {
          mgr.show_hidden = true;
          opener.edit = [
            {
              run = ''nvim "$@"'';
              desc = "Edit with Neovim";
              block = true;
            }
          ];
          open.prepend_rules = [
            {
              mime = "text/*";
              use = "edit";
            }
          ];
        };
      };
    }
  ];
}
