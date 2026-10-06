local options = {
	clipboard = "unnamed,unnamedplus",
	cmdheight = 0,
	completeopt = "menu,menuone,noselect",
	emoji = false,
	expandtab = true,
	ignorecase = true,
	laststatus = 3,
	mouse = "a",
	number = true,
	relativenumber = true,
	pumblend = 10,
	pumheight = 10,
	scrolloff = 8,
	shiftwidth = 2,
	smartcase = true,
	smartindent = true,
	smarttab = true,
	splitbelow = true,
	splitright = true,

	swapfile = false,
	tabstop = 2,
	softtabstop = 2,
	termguicolors = true,
	timeoutlen = 500,
	updatetime = 100,
	wildignore = { "*/node_modules/**" },
	wrap = false,
	backup = false,
	writebackup = false,
	autoindent = true,
	breakindent = true,
	backspace = "indent,eol,start",
	showmode = true,
	undofile = true,
	background = "dark",
	incsearch = true,
	encoding = "utf-8",
	fileencoding = "utf-8",
	autowrite = true,
	showmatch = true,
	hlsearch = false,
	title = true,
	backupskip = "/tmp/*,/private/tmp*",
	grepformat = "%f:%l:%c:%m",
	grepprg = "rg --vimgrep --no-heading --smart-case",
	signcolumn = "yes",
}

local globals = {
	mapleader = " ",
}

vim.opt.path:append({ "**" })

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

for k, v in pairs(options) do
	vim.opt[k] = v
end

for k, v in pairs(globals) do
	vim.g[k] = v
end

for _, provider in ipairs({ "node", "perl", "python3", "ruby" }) do
	vim.g["loaded_" .. provider .. "_provider"] = 0
end

vim.diagnostic.config({
	virtual_text = true,
})
