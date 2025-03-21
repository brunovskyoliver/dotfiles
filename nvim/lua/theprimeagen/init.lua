require("theprimeagen.set")
require("theprimeagen.remap")
require("theprimeagen.lazy_init")


local distant_telescope = require('theprimeagen.distant_telescope')
distant_telescope.setup()

vim.api.nvim_create_user_command('DistantFiles', function(opts)
    distant_telescope.find_remote_files({ path = opts.args })
end, { nargs = '?' })
vim.keymap.set('n', '<leader>rf', '<Cmd>DistantFiles<CR>', { desc = 'Find remote files' })

function DistantCdToCurrentFileInNewTab()
    -- Get the full path of the currently open file
    local file_path = vim.fn.expand("%:p:h")

    -- Ensure we are in a Distant session
    if file_path:match("^term://") then
        print("This command should be used on a remote Distant file, not a local terminal.")
        return
    end

    -- Fix Distant path issues: Remove "distant://<ID>://"
    local fixed_path = file_path:gsub("^distant://%d+://", "")

    -- Validate extracted path
    if fixed_path == "" or fixed_path == file_path then
        print("Could not resolve a valid remote path.")
        return
    end

    -- Open a new tab and start DistantShell in the correct directory
    vim.cmd("tabnew") -- Open a new tab
    vim.cmd(string.format(":DistantShell cd \"%s\" && exec $SHELL", fixed_path))

    print("Opened DistantShell in a new tab:", fixed_path)
end

-- Keybinding to run the function
vim.api.nvim_set_keymap("n", "<leader>dc", ":lua DistantCdToCurrentFileInNewTab()<CR>", { noremap = true, silent = true })




-- DO.not
-- DO NOT INCLUDE THIS

-- If i want to keep doing lsp debugging
-- function restart_htmx_lsp()
--     require("lsp-debug-tools").restart({ expected = {}, name = "htmx-lsp", cmd = { "htmx-lsp", "--level", "DEBUG" }, root_dir = vim.loop.cwd(), });
-- end

-- DO NOT INCLUDE THIS
-- DO.not

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})


autocmd("BufWritePre", {
    group = ThePrimeagenGroup,
    pattern = "*",
    callback = function()
        -- Trim trailing whitespace
        vim.cmd([[ %s/\s\+$//e ]])

        -- Run conform.nvim formatting
        require("conform").format()
    end,
})

autocmd('BufEnter', {
    group = ThePrimeagenGroup,
    callback = function()
        if vim.bo.filetype == "zig" then
            vim.cmd.colorscheme("tokyonight-night")
        else
            vim.cmd.colorscheme("rose-pine-moon")
        end
    end
})


autocmd('LspAttach', {
    group = ThePrimeagenGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.expand("%") == "" then
            vim.bo.modified = false
        end
    end,
})

vim.api.nvim_create_user_command("Glow", function()
    local file = vim.fn.expand("%:p")
    local cmd = "glow " .. vim.fn.shellescape(file)
    vim.cmd("split | terminal " .. cmd)
end, {})
