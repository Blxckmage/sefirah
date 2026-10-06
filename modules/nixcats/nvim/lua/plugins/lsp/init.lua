require("util.event").lazy_file()

return {
	"neovim/nvim-lspconfig",
	name = "nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	config = function(_, opts)
		require("plugins.lsp.handlers").setup(_, opts)
	end,
}
