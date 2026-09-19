return {
	"dmtrKovalenko/fff.nvim",
	-- NOTE 2026-09-17: fff.nvim SIGSEGVs when launched from $HOME ("Refusing
	-- to index home directory"). Only use ff/fg/fz inside project subdirs,
	-- never from ~ or /.
	build = function()
		require("fff.download").download_or_build_binary()
	end,
	opts = {
		debug = {
			enabled = true,
			show_scores = true,
		},
	},
	lazy = false,
	keys = {
		{
			"ff",
			function()
				require("fff").find_files()
			end,
			desc = "Find Files (fff)",
		},
		{
			"fg",
			function()
				require("fff").live_grep()
			end,
			desc = "Live Grep (fff)",
		},
		{
			"fz",
			function()
				require("fff").live_grep({
					grep = {
						modes = { "fuzzy", "plain" },
					},
				})
			end,
			desc = "Fuzzy Search (fff)",
		},
		{
			"fc",
			function()
				require("fff").live_grep({ query = vim.fn.expand("<cword>") })
			end,
			desc = "Search Current Word (fff)",
		},
	},
}
