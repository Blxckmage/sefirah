vim.api.nvim_create_autocmd("BufEnter", {
	command = [[set formatoptions-=cro]],
})

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

local function set_normal_float_highlight()
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = set_normal_float_highlight,
})
