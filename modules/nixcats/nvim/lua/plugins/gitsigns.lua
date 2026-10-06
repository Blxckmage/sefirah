return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
	},
	keys = {
		{
			"]c",
			function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					require("gitsigns").nav_hunk("next")
				end)
				return "<Ignore>"
			end,
			mode = "n",
			expr = true,
			desc = "Next hunk",
		},
		{
			"[c",
			function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					require("gitsigns").nav_hunk("prev")
				end)
				return "<Ignore>"
			end,
			mode = "n",
			expr = true,
			desc = "Previous hunk",
		},
		{
			"<leader>hs",
			function()
				require("gitsigns").stage_hunk()
			end,
			mode = "n",
			desc = "Stage hunk",
		},
		{
			"<leader>hr",
			function()
				require("gitsigns").reset_hunk()
			end,
			mode = "n",
			desc = "Reset hunk",
		},
		{
			"<leader>hp",
			function()
				require("gitsigns").preview_hunk()
			end,
			mode = "n",
			desc = "Preview hunk",
		},
		{
			"<leader>hb",
			function()
				require("gitsigns").blame_line({ full = true })
			end,
			mode = "n",
			desc = "Blame line",
		},
	},
}
