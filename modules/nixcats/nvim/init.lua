require("core.options")
require("core.keymaps")
require("core.autocmds")

if vim.loader then
	vim.loader.enable()
end

require("nixCatsUtils").setup({ non_nix_value = true })

require("nixCatsUtils.lazyCat").setup(nixCats.pawsible({ "allPlugins", "start", "lazy.nvim" }), {
	{ import = "plugins" },
}, {
	defaults = {
		lazy = false,
		version = false,
	},
	dev = {
		fallback = false,
	},
	checker = { enabled = false, notify = false },
	change_detection = {
		enabled = false,
	},
	performance = {
		rtp = {

			disabled_plugins = {
				"gzip",

				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"colors",
			},
		},
	},
})
