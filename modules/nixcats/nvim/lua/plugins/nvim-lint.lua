require("util.event").lazy_file()

return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPost", "BufWritePost", "BufNewFile" },

	opts = {
		events = { "BufWritePost", "BufReadPost", "InsertLeave" },
		linters_by_ft = {
			javascript = { "eslint_d" },
			typescript = { "eslint_d" },
			javascriptreact = { "eslint_d" },
			typescriptreact = { "eslint_d" },
			svelte = { "eslint_d" },
			python = { "flake8" },
		},
		linters = {},
	},
	config = function(_, opts)
		local lint = require("lint")
		lint.linters_by_ft = opts.linters_by_ft

		lint.linters.eslint_d = require("lint.util").wrap(lint.linters.eslint_d, function(diagnostic)

			if diagnostic.message:find("Error: Could not find config file") then
				return nil
			end
			return diagnostic
		end)

		vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
			group = vim.api.nvim_create_augroup("lint", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
