return {
    {
        "stevearc/oil.nvim",
        lazy = false, -- replaces netrw for `nvim .`
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = { { "-", "<cmd>Oil<CR>", desc = "Open parent directory" } },
        opts = {
            view_options = { show_hidden = true },
            keymaps = {
                ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
            },
        },
    },
    {
        "ibhagwan/fzf-lua",
        cmd = "FzfLua",
        keys = {
            { "<leader>ff", "<cmd>FzfLua files<CR>" },
            { "<C-p>", "<cmd>FzfLua git_files<CR>" },
            { "<leader>ws", "<cmd>FzfLua grep_cword<CR>" },
            { "<leader>Ws", "<cmd>FzfLua grep_cWORD<CR>" },
            { "<leader>gr", "<cmd>FzfLua grep<CR>" },
            { "<leader>vh", "<cmd>FzfLua helptags<CR>" },
        },
        opts = {},
    },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = function()
            local function list() return require("harpoon"):list() end
            local keys = {
                { "<leader>h", function() list():add() end },
                { "<leader>l", function() require("harpoon").ui:toggle_quick_menu(list()) end },
            }
            for i = 1, 5 do
                table.insert(keys, { "<leader>" .. i, function() list():select(i) end })
            end
            return keys
        end,
        config = function()
            require("harpoon"):setup()
        end,
    },
    {
        "mbbill/undotree",
        keys = { { "<leader>u", function()
            vim.cmd.UndotreeToggle()
            vim.cmd.UndotreeFocus()
        end } },
    },
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit" },
        keys = {
            { "<leader>gs", "<cmd>Git<CR>" },
            { "gu", "<cmd>diffget //2<CR>" },
            { "gh", "<cmd>diffget //3<CR>" },
        },
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "fugitive",
                callback = function(e)
                    local opts = { buffer = e.buf }
                    vim.keymap.set("n", "<leader>gp", function() vim.cmd.Git("push") end, opts)
                    vim.keymap.set("n", "<leader>P", function() vim.cmd.Git({ "pull", "--rebase" }) end, opts)
                    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
                end,
            })
        end,
    },
    {
        "NeogitOrg/neogit",
        cmd = "Neogit",
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim", "ibhagwan/fzf-lua" },
        opts = {},
    },
    { "wakatime/vim-wakatime", event = "VeryLazy" },
}
