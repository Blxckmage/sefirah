{ inputs, self, ... }:
{
  perSystem = { system, ... }: {
    packages.nvim =
      let
        categoryDefinitions = { pkgs, ... }: {
        lspsAndRuntimeDeps.general = with pkgs; [
          lua-language-server
          vscode-langservers-extracted
          vtsls
          biome
          tailwindcss-language-server
          intelephense
          clang-tools
          gopls
          go
          basedpyright
          ruff
          nixd
          prettierd
          prettier
          stylua
          black
          phpPackages.php-cs-fixer
          eslint_d
          python3Packages.flake8
          nixfmt
          statix
          deadnix
        ];
        startupPlugins.general = with pkgs.vimPlugins; [
          lazy-nvim
          mini-nvim
          mini-icons
          blink-cmp
          luasnip
          friendly-snippets
          copilot-lua
          nvim-lspconfig
          conform-nvim
          nvim-lint
          nvim-treesitter
          (nvim-treesitter.withPlugins (grammars: with grammars; [
            bash
            c
            cpp
            css
            go
            gotmpl
            html
            javascript
            json
            lua
            markdown
            markdown_inline
            nix
            php
            proto
            python
            regex
            svelte
            tsx
            typescript
            typst
            vim
            vimdoc
          ]))
          nvim-treesitter-context
          nvim-ts-autotag
          nvim-ts-context-commentstring
          snacks-nvim
          noice-nvim
          nui-nvim
          bufferline-nvim
          harpoon2
          yanky-nvim
          todo-comments-nvim
          trouble-nvim
          nvim-colorizer-lua
          nvim-web-devicons
          plenary-nvim
          fff-nvim
          render-markdown-nvim
          gitsigns-nvim
          typst-preview-nvim
          orgmode
          everforest
          (pkgs.vimUtils.buildVimPlugin {
            pname = "org-bullets.nvim";
            version = "503fe05";
            src = pkgs.fetchFromGitHub {
              owner = "akinsho";
              repo = "org-bullets.nvim";
              rev = "503fe053550879cc202086a40454e46a87c41ddb";
              hash = "sha256-Tgeqr/Zd1hJXXaln4XWGS5aZqypnpfNxgO/+pQVk7jg=";
            };
          })
        ];
      };
      packageDefinitions = {
        nvim = { pkgs, ... }: {
          settings = {
            aliases = [ "vi" "vim" ];
          };
          categories = {
            general = true;
          };
        };
      };
      in
      (inputs.nixCats.utils.baseBuilder ./nvim {
        inherit (inputs) nixpkgs;
        inherit system;
        extra_pkg_config.allowUnfree = true;
      } categoryDefinitions packageDefinitions) "nvim";
  };
}
