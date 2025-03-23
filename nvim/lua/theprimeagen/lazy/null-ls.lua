return {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "williamboman/mason.nvim", "jay-babu/mason-null-ls.nvim" },
    config = function()
        local null_ls = require("null-ls")
        require("mason-null-ls").setup({
            ensure_installed = { "xmlformatter" }, -- Ensures xmlformatter is installed
            automatic_installation = true,
        })

        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.xmlformat,
                null_ls.builtins.formatting.black
            },
        })
    end
}
