require("settings")
require("plugins")
require("maps")
--local themeStatus, dracula = pcall(require, "dracula")

--if themeStatus then
--    vim.cmd("colorscheme dracula")
--else
--    return
--end


local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug 'Mofiqul/dracula.nvim'
vim.call('plug#end')

vim.cmd('silent! colorscheme dracula')
vim.opt.termguicolors = true
require'lspconfig'.pyright.setup{}
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.py",
    callback = function()
        vim.cmd([[%s/\s\+$//e]])
    end,
})


