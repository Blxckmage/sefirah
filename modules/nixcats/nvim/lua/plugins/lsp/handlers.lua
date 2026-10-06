local M = {}

M.setup = function(_, opts)
	local lspconfig = require("lspconfig")
	vim.api.nvim_create_autocmd("LspAttach", {
		desc = "LSP Keymaps",
		callback = function(event)
			local function map(mode, keys, func, desc)
				vim.keymap.set(mode, keys, func, {
					buffer = event.buf,
					noremap = true,
					silent = true,
					desc = desc .. " (LSP)",
				})
			end

			map("n", "K", vim.lsp.buf.hover, "Show hover")
			map("n", "grn", vim.lsp.buf.rename, "Rename")
			map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
			map("n", "<C-j>", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, "Next diagnostic")
			map("i", "<C-h>", vim.lsp.buf.signature_help, "Signature help")
		end,
	})

	local capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
	}

	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

	local servers = {
		"lua_ls",
		"html",
		"cssls",
		"vtsls",
		"biome",
		"tailwindcss",
		"intelephense",
	}

	local servers_path = require("nixCats").configDir .. "/lua/plugins/lsp/servers"
	local server_files = vim.fn.glob(servers_path .. "/*.lua", false, true)

	for _, file in ipairs(server_files) do
		local server_name = vim.fn.fnamemodify(file, ":t:r")
		if not vim.tbl_contains(servers, server_name) then
			table.insert(servers, server_name)
		end
	end

	for _, server in ipairs(servers) do
		local server_opts = {}

		local ok, config = pcall(require, "plugins.lsp.servers." .. server)
		if ok then
			server_opts = config
		end

		server_opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})

		vim.lsp.config(server, server_opts)
		vim.lsp.enable(server)
	end

	require("snacks").util.lsp.on({ name = "gopls" }, function(_, client)
		if not client.server_capabilities.semanticTokensProvider then
			local semantic = client.config.capabilities.textDocument.semanticTokens
			client.server_capabilities.semanticTokensProvider = {
				full = true,
				legend = {
					tokenTypes = semantic.tokenTypes,
					tokenModifiers = semantic.tokenModifiers,
				},
				range = true,
			}
		end
	end)
end

return M
