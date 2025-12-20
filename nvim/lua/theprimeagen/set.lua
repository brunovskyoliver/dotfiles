vim.opt.guicursor = ""

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.o.paste = false
vim.opt.clipboard:append("unnamedplus")
vim.opt.colorcolumn = "80"
vim.api.nvim_create_augroup("view_autosave", { clear = true })

-- Save view on leaving a window if the buffer has a valid name and is a normal file.
vim.api.nvim_create_autocmd("BufWinLeave", {
	group = "view_autosave",
	pattern = "*",
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname == "" or vim.bo.buftype ~= "" then
			return
		end
		vim.cmd("mkview")
	end,
})

-- Restore view on entering a window if the buffer has a valid name and is a normal file.
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = "view_autosave",
	pattern = "*",
	callback = function()
		local bufname = vim.api.nvim_buf_get_name(0)
		if bufname == "" or vim.bo.buftype ~= "" then
			return
		end
		vim.cmd("silent! loadview")
	end,
})
vim.g.loaded_python3_provider = 0

vim.env.DOTNET_ROOT = "/usr/local/share/dotnet"
