return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "ray-x/lsp_signature.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                xml = { "xmlformatter" },
            },
            -- format_on_save = { -- Automatically format on save
            --     timeout_ms = 1000,
            --     lsp_fallback = true,
            -- }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()

        local lspconfig = require("lspconfig")
        local omnisharp_cmd = vim.fn.stdpath("data") .. "/mason/bin/omnisharp"
        local omnisharp_command = {
            omnisharp_cmd,
            "-z",
            "--hostPID",
            tostring(vim.fn.getpid()),
            "DotNet:enablePackageRestore=false",
            "--encoding",
            "utf-8",
            "--languageserver",
        }
        local omnisharp_capabilities = vim.tbl_deep_extend(
            "force",
            {},
            capabilities,
            { workspace = { workspaceFolders = false } }
        )
        local omnisharp_config = {
            -- OmniSharp uses its process directory to discover projects. The
            -- native LSP API does not automatically set it to root_dir.
            cmd = function(dispatchers, config)
                return vim.lsp.rpc.start(omnisharp_command, dispatchers, {
                    cwd = config.root_dir,
                    env = config.cmd_env,
                    detached = config.detached,
                })
            end,
            capabilities = omnisharp_capabilities,
            settings = {
                FormattingOptions = {
                    EnableEditorConfigSupport = true,
                    OrganizeImports = true,
                },
                MsBuild = {
                    LoadProjectsOnDemand = true,
                },
                RoslynExtensionsOptions = {
                    EnableAnalyzersSupport = true,
                    EnableImportCompletion = true,
                },
            },
        }

        -- Neovim 0.11+ uses the native LSP configuration API. Older
        -- mason-lspconfig releases use the handlers table below instead.
        local has_native_omnisharp = vim.fn.has("nvim-0.11") == 1
            and #vim.api.nvim_get_runtime_file("lsp/omnisharp.lua", true) > 0

        if has_native_omnisharp then
            vim.lsp.config("omnisharp", omnisharp_config)
        end

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "omnisharp",
            },
            -- The native setup above owns OmniSharp on current versions.
            automatic_enable = has_native_omnisharp and { exclude = { "omnisharp" } } or nil,
            handlers = {
                function(server_name) -- default handler (optional)
                    lspconfig[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                zls = function()
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,
                ["omnisharp"] = function()
                    lspconfig.omnisharp.setup(vim.tbl_deep_extend(
                        "force",
                        {},
                        omnisharp_config,
                        {
                            root_dir = lspconfig.util.root_pattern(
                                "*.slnx",
                                "*.sln",
                                "*.csproj",
                                "omnisharp.json",
                                "function.json",
                                "Assets",
                                "ProjectSettings"
                            ),
                        }
                    ))
                end,
                ["lua_ls"] = function()
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each", "love" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        if has_native_omnisharp then
            vim.lsp.enable("omnisharp")
        end

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                --{ name = "copilot", group_index = 2 },
                {
                    name = 'nvim_lsp',
                    entry_filter = function(entry)
                        -- Avoid auto-snippet parentheses from LSP
                        local kind = entry:get_kind()
                        return kind ~= vim.lsp.protocol.CompletionItemKind.Snippet
                    end,
                },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'path' },
            }, {
                { name = 'buffer' },
            })
        }
        )
        vim.api.nvim_create_autocmd("InsertCharPre", {
            pattern = "*.go",
            callback = function()
                local char = vim.v.char
                if char == "(" or char == "," then
                    vim.defer_fn(function()
                        vim.lsp.buf.signature_help()
                    end, 20)
                end
            end,
        })
        require("lsp_signature").setup({
            bind = true,
            floating_window = true,
            hint_enable = false,
            handler_opts = {
                border = "rounded"
            },
        })


        vim.diagnostic.config({
            -- virtual_text = false,
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
