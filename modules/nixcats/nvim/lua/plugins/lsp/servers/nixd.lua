return {
	filetypes = { "nix" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = 'import (builtins.getFlake "/home/blackmage/.config/nixpkgs").inputs.nixpkgs { }',
			},
			formatting = {
				command = { "nixfmt" },
			},
			options = {
				nixos = {
					expr = '(builtins.getFlake "/home/blackmage/.config/nixpkgs").nixosConfigurations.sefirah.options',
				},
				["home-manager"] = {
					expr = '(builtins.getFlake "/home/blackmage/.config/nixpkgs").nixosConfigurations.sefirah.options.home-manager.users.type.getSubOptions []',
				},
			},
		},
	},
}
