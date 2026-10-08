local opt = vim.opt

opt.guicursor = ""
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = true
opt.swapfile = false
opt.backup = false
opt.undodir = vim.env.HOME .. "/.vim/undodir"
opt.undofile = true
opt.hlsearch = false
opt.incsearch = true
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")
opt.updatetime = 250
opt.colorcolumn = "80"
opt.winborder = "rounded"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Unused remote-plugin providers; skipping them saves startup time.
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

vim.env.DOTNET_ROOT = "/usr/local/share/dotnet"

vim.filetype.add({ extension = { templ = "templ" } })
