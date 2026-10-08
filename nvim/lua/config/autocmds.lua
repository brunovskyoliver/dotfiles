local group = vim.api.nvim_create_augroup("Oliver", {})
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
    group = group,
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 40 })
    end,
})

-- Remember folds and cursor per file.
local function normal_file(buf)
    return vim.api.nvim_buf_get_name(buf) ~= "" and vim.bo[buf].buftype == ""
end
autocmd("BufWinLeave", {
    group = group,
    callback = function(e)
        if normal_file(e.buf) then
            vim.cmd("silent! mkview")
        end
    end,
})
autocmd("BufWinEnter", {
    group = group,
    callback = function(e)
        if normal_file(e.buf) then
            vim.cmd("silent! loadview")
        end
    end,
})

autocmd("LspAttach", {
    group = group,
    callback = function(e)
        local function map(lhs, rhs)
            vim.keymap.set("n", lhs, rhs, { buffer = e.buf })
        end
        map("gd", vim.lsp.buf.definition)
        map("K", vim.lsp.buf.hover)
        map("<leader>vws", vim.lsp.buf.workspace_symbol)
        map("<leader>vd", vim.diagnostic.open_float)
        map("<leader>vca", vim.lsp.buf.code_action)
        map("<leader>vrr", vim.lsp.buf.references)
        map("<leader>rn", vim.lsp.buf.rename)
        -- [d and ]d are Neovim defaults.
    end,
})

vim.api.nvim_create_user_command("Glow", function()
    vim.cmd("split | terminal glow " .. vim.fn.shellescape(vim.fn.expand("%:p")))
end, {})
