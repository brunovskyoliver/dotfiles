return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "williamboman/mason.nvim",
        "jay-babu/mason-null-ls.nvim",
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local null_ls = require("null-ls") -- ← keep this as "null-ls", not "none-ls"

        require("mason-null-ls").setup({
            -- ensure_installed = { "xmlformatter" },
            automatic_installation = true,
        })

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.xmlformat,
                null_ls.builtins.formatting.black,
            },
        })
    end,
}
