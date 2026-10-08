return {
    {
        "lervag/vimtex",
        lazy = false, -- inverse search needs it in a fresh process
        init = function()
            vim.g.tex_flavor = "latex"
            vim.g.vimtex_view_method = "skim"
            vim.g.vimtex_view_skim_activate = 0
            vim.g.vimtex_view_skim_sync = 1
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_compiler_method = vim.fn.executable("latexmk") == 1 and "latexmk" or "tectonic"
            vim.cmd([[
                let g:vimtex_compiler_latexmk = {
                    \ 'out_dir': {info -> luaeval("require('config.latex').build_directory(_A)", info.root)},
                    \ }
                let g:vimtex_compiler_tectonic = {
                    \ 'out_dir': {info -> luaeval("require('config.latex').build_directory(_A)", info.root)},
                    \ 'options': ['--keep-logs', '--keep-intermediates', '--synctex'],
                    \ }
            ]])
        end,
        config = function()
            require("config.latex").setup()
        end,
    },
    {
        "obsidian-nvim/obsidian.nvim",
        version = "*",
        ft = "markdown",
        opts = {
            legacy_commands = false,
            workspaces = {
                {
                    name = "brunovsky",
                    path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/brunovsky",
                },
            },
        },
    },
    {
        "toppair/peek.nvim",
        build = "deno task --quiet build:fast",
        cmd = { "PeekOpen", "PeekClose" },
        config = function()
            require("peek").setup({ filetype = { "markdown", "conf" } })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    },
}
