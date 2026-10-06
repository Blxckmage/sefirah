require("util.event").lazy_file()

return {
	{
		"nvim-treesitter/nvim-treesitter",
		name = "nvim-treesitter",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf = args.buf
					local language = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
					if not language then
						return
					end
					if not vim.treesitter.language.add(language) then
						return
					end
					vim.treesitter.start(buf, language)
					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		enabled = true,
		opts = { mode = "cursor", max_lines = 3 },
	},
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		opts = {},
	},
	{
		"JoosepAlviste/nvim-ts-context-commentstring",
		lazy = true,
		opts = {
			enable_autocmd = false,
		},
	},
}
