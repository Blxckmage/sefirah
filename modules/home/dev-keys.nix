{ ... }:
{
  config.sefirah.homeModules = [
    ({ pkgs, ... }: {
      programs.gpg.enable = true;
      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-curses;
        defaultCacheTtl = 86400;
        maxCacheTtl = 86400;
        enableSshSupport = false; # plain ssh-agent below owns SSH
      };
      services.ssh-agent.enable = true;
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "*" = {
            AddKeysToAgent = "yes";
          };
          "github.com" = {
            User = "git";
            IdentitiesOnly = "yes";
            IdentityFile = "~/.ssh/id_ed25519";
          };
        };
      };
      programs.git = {
        enable = true;
        signing = {
          key = "/home/blackmage/.ssh/id_sign.pub";
          signByDefault = true;
        };
        settings = {
          user.name = "Faza Zikri";
          user.email = "fazadoang15@gmail.com";
          gpg.format = "ssh";
          init.defaultBranch = "main";
          pull.rebase = true;
        };
      };
    })
  ];
}
