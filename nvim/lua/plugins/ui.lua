function ColorMyPencils(color)
    vim.cmd.colorscheme(color or "rose-pine-moon")
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = false,
        priority = 1000,
        config = function()
            require("rose-pine").setup({ disable_background = true, styles = { italic = false } })
            ColorMyPencils()
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = { theme = "gruvbox", section_separators = "", component_separators = "" },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            extensions = { "fugitive", "oil", "trouble" },
        },
    },
    {
        "folke/zen-mode.nvim",
        keys = {
            { "<leader>zz", function()
                require("zen-mode").toggle({ window = { width = 90 } })
                vim.wo.wrap = false
                vim.wo.number = true
                vim.wo.rnu = true
                ColorMyPencils()
            end },
            { "<leader>zZ", function()
                require("zen-mode").toggle({ window = { width = 80 } })
                vim.wo.wrap = false
                vim.wo.number = false
                vim.wo.rnu = false
                vim.opt.colorcolumn = "0"
                ColorMyPencils()
            end },
        },
    },
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = {},
        keys = {
            { "<leader>tt", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
            { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
            { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs" },
            { "<leader>tL", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
            { "<leader>tQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
        },
    },
    {
        "laytan/cloak.nvim",
        event = { { event = { "BufReadPre", "BufNewFile" }, pattern = { ".env*", "wrangler.toml", ".dev.vars" } } },
        opts = {
            cloak_character = "*",
            highlight_group = "Comment",
            patterns = {
                { file_pattern = { ".env*", "wrangler.toml", ".dev.vars" }, cloak_pattern = "=.+" },
            },
        },
    },
}
