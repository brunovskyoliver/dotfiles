return {
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        config = function()
            local ls = require("luasnip")
            require("luasnip.loaders.from_vscode").lazy_load()
            ls.filetype_extend("javascript", { "jsdoc" })
            vim.keymap.set("i", "<C-k>", function() ls.expand() end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-j>", function() ls.jump(1) end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-h>", function() ls.jump(-1) end, { silent = true })
            vim.keymap.set({ "i", "s" }, "<C-l>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, { silent = true })
        end,
    },
    {
        "saghen/blink.cmp",
        version = "1.*",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = { "L3MON4D3/LuaSnip" },
        opts = {
            keymap = {
                preset = "none",
                ["<Down>"] = { "select_next", "fallback" },
                ["<Up>"] = { "select_prev", "fallback" },
                ["<C-n>"] = { "select_next", "fallback" },
                ["<C-p>"] = { "select_prev", "fallback" },
                ["<CR>"] = { "accept", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<Tab>"] = {
                    function()
                        local ls = require("luasnip")
                        if ls.expandable() then
                            vim.schedule(ls.expand)
                            return true
                        end
                    end,
                    "snippet_forward",
                    "fallback",
                },
                ["<S-Tab>"] = { "snippet_backward", "fallback" },
            },
            snippets = { preset = "luasnip" },
            completion = {
                accept = { auto_brackets = { enabled = false } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
            },
            signature = { enabled = true },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
                providers = {
                    lsp = {
                        -- Drop LSP snippet items (auto-inserted parentheses),
                        -- except in YAML where keys come as snippets.
                        transform_items = function(_, items)
                            if vim.bo.filetype:match("^yaml") then
                                return items
                            end
                            local snippet = require("blink.cmp.types").CompletionItemKind.Snippet
                            return vim.tbl_filter(function(item) return item.kind ~= snippet end, items)
                        end,
                    },
                },
            },
        },
    },
}
