require("util.event").lazy_file()

return {
	{
		"echasnovski/mini.nvim",
		name = "mini.nvim",
		event = "VeryLazy",
		config = function()
			require("mini.pairs").setup()
			require("mini.indentscope").setup({
				symbol = "│",
				options = { try_as_border = true },
			})
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return require("ts_context_commentstring.internal").calculate_commentstring()
							or vim.bo.commentstring
					end,
				},
			})
			require("mini.surround").setup({
				mappings = {
					add = "gsa",
					delete = "gsd",
					find = "gsf",
					find_left = "gsF",
					highlight = "gsh",
					replace = "gsr",
					update_n_lines = "gsn",
				},
			})
			require("mini.files").setup({
				windows = {
					preview = true,
					width_focus = 30,
					width_preview = 40,
				},
				options = {
					use_as_default_explorer = false,
				},
			})
			require("mini.statusline").setup({
				content = {
					active = function()
						local MiniStatusline = require("mini.statusline")
						local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
						local filename = MiniStatusline.section_filename({ trunc_width = 140 })
						return MiniStatusline.combine_groups({
							{ hl = mode_hl, strings = { mode:upper() } },
							"%<",
							{ hl = "MiniStatuslineFilename", strings = { filename } },
							"%=",
							{
								hl = "MiniStatuslineFileinfo",
								strings = {
									vim.bo.filetype ~= ""
										and require("mini.icons").get("filetype", vim.bo.filetype)
											.. " "
											.. vim.bo.filetype,
								},
							},
							{ hl = mode_hl, strings = { "%l:%v" } },
						})
					end,
				},
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"lazy",
					"mason",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
			local show_dotfiles = true
			local filter_show = function(fs_entry)
				return true
			end
			local filter_hide = function(fs_entry)
				return not vim.startswith(fs_entry.name, ".")
			end
			local toggle_dotfiles = function()
				show_dotfiles = not show_dotfiles
				local new_filter = show_dotfiles and filter_show or filter_hide
				require("mini.files").refresh({ content = { filter = new_filter } })
			end
			local map_split = function(buf_id, lhs, direction, close_on_file)
				local rhs = function()
					local new_target_window
					local cur_target_window = require("mini.files").get_target_window()
					if cur_target_window ~= nil then
						vim.api.nvim_win_call(cur_target_window, function()
							vim.cmd("belowright " .. direction .. " split")
							new_target_window = vim.api.nvim_get_current_win()
						end)
						require("mini.files").set_target_window(new_target_window)
						require("mini.files").go_in({ close_on_file = close_on_file })
					end
				end
				local desc = "Open in " .. direction .. " split"
				if close_on_file then
					desc = desc .. " and close"
				end
				vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
			end
			local files_set_cwd = function()
				local cur_entry_path = require("mini.files").get_current_entry_path()
				local cur_directory = vim.fs.dirname(cur_entry_path)
				if cur_directory ~= nil then
					vim.fn.chdir(cur_directory)
				end
			end
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesBufferCreate",
				callback = function(args)
					local buf_id = args.data.buf_id
					vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })
					vim.keymap.set("n", "gc", files_set_cwd, { buffer = buf_id, desc = "Set cwd" })
					map_split(buf_id, "<C-w>s", "horizontal", false)
					map_split(buf_id, "<C-w>v", "vertical", false)
					map_split(buf_id, "<C-w>S", "horizontal", true)
					map_split(buf_id, "<C-w>V", "vertical", true)
				end,
			})
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniFilesActionRename",
				callback = function(event)
					local changes = {
						files = {
							{
								oldUri = vim.uri_from_fname(event.data.from),
								newUri = vim.uri_from_fname(event.data.to),
							},
						},
					}
					local clients = vim.lsp.get_clients and vim.lsp.get_clients() or vim.lsp.get_active_clients()
					for _, client in ipairs(clients) do
						if client.supports_method("workspace/willRenameFiles") then
							local resp = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
							if resp and resp.result ~= nil then
								vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
							end
						end
						if client.supports_method("workspace/didRenameFiles") then
							client.notify("workspace/didRenameFiles", changes)
						end
					end
				end,
			})
		end,
		keys = {
			{
				"<leader>bd",
				function()
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice =
							vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
						if choice == 1 then
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
			{
				"<leader>=",
				function()
					require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
				end,
				desc = "Open mini.files (Directory of Current File)",
			},
			{
				"<leader>+",
				function()
					require("mini.files").open(vim.uv.cwd(), true)
				end,
				desc = "Open mini.files (cwd)",
			},
			{ "gc", mode = { "n", "o" }, desc = "Comment toggle linewise" },
			{ "gcc", mode = "n", desc = "Comment toggle current line" },
			{ "gc", mode = "x", desc = "Comment toggle linewise (visual)" },
			{ "gsa", mode = { "n", "v" }, desc = "Add surrounding" },
			{ "gsd", desc = "Delete surrounding" },
			{ "gsf", desc = "Find right surrounding" },
			{ "gsF", desc = "Find left surrounding" },
			{ "gsh", desc = "Highlight surrounding" },
			{ "gsr", desc = "Replace surrounding" },
			{ "gsn", desc = "Update MiniSurround.config.n_lines" },
		},
	},
}
