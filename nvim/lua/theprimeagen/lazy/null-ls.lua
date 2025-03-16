local null_ls = require("null-ls")

return {
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.xmlformat, -- Add xmlformatter
            },
        })
}

