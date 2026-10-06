return {
	filetypes = { "python" },
	cmd = { "ruff", "server", "--preview" },
	settings = {

		configuration = vim.fn.getcwd() .. "/pyproject.toml",

		organizeImports = true,

		fixAll = true,
		lint = {

			enable = true,

			select = { "ALL" },

			ignore = {
				"E501",
				"D",
			},
		},
		format = {

			enable = true,
		},
	},
}
