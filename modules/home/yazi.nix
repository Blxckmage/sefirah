{ ... }:
{
  config.sefirah.homeModules = [
    {
      programs.yazi = {
        enable = true;
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
