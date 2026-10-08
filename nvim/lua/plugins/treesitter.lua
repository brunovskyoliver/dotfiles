local parsers = {
    "bash", "bibtex", "c", "c_sharp", "cpp", "css", "diff", "dockerfile", "gitcommit", "go",
    "gomod", "gosum", "html", "javascript", "jsdoc", "json", "latex", "lua", "luadoc", "make",
    "markdown", "markdown_inline", "python", "query", "rust", "templ", "toml", "typescript",
    "vim", "vimdoc", "xml", "yaml",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- does not support lazy loading
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            callback = function(e)
                local lang = vim.treesitter.language.get_lang(e.match)
                if not lang or lang == "latex" then -- VimTeX owns LaTeX
                    return
                end
                local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(e.buf))
                if stat and stat.size > 100 * 1024 then
                    return
                end
                if pcall(vim.treesitter.start, e.buf, lang) then
                    vim.bo[e.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
