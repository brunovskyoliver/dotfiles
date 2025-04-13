return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
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
        "Hoffs/omnisharp-extended-lsp.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
                xml = { "xmlformatter" },
            },
            format_on_save = { -- Automatically format on save
                timeout_ms = 1000,
                lsp_fallback = true,
            }
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
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "omnisharp",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                zls = function()
                    local lspconfig = require("lspconfig")
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
                    local lspconfig = require("lspconfig")
                    local omnisharp_extended = require("omnisharp_extended")

                    vim.env.DOTNET_ROOT = "/usr/local/share/dotnet"
                    vim.env.MSBUILD_EXE_PATH = "/Library/Frameworks/Mono.framework/Versions/Current/Commands/msbuild"
                    lspconfig.omnisharp.setup({
                        cmd = {
                            -- "dotnet",
                            -- "/Users/oliver/.local/bin/omnisharp/OmniSharp.dll",
                            "mono",
                            -- Path to the OmniSharp.exe from the mono build you just extracted:
                            "/Users/oliver/.local/bin/omnisharp-mono/OmniSharp.exe",
                            "--languageserver",
                            "--hostPID",
                            tostring(vim.fn.getpid())
                        },
                        root_dir = lspconfig.util.root_pattern("BazDef.sln"),
                        capabilities = require("cmp_nvim_lsp").default_capabilities(),
                        handlers = {
                            ["textDocument/definition"] = omnisharp_extended.handler,
                        },
                        on_attach = function(client, bufnr)
                            print("✅ OmniSharp LSP attached to buffer " .. bufnr)
                        end,
                        settings = {
                            FormattingOptions = {
                                EnableEditorConfigSupport = true,
                                OrganizeImports = true,
                            },
                            RoslynExtensionsOptions = {
                                EnableAnalyzersSupport = false,
                                EnableImportCompletion = false,
                                AnalyzeOpenDocumentsOnly = true,
                            },
                            MsBuild = {
                                LoadProjectsOnDemand = true,
                            },
                            Sdk = {
                                IncludePrereleases = true,
                            },
                        },
                    })
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
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
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'path' },
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
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
