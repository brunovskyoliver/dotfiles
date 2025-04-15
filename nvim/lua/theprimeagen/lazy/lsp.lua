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
                -- ["omnisharp"] = function()
                --     local lspconfig = require("lspconfig")
                --     local omnisharp_extended = require("omnisharp_extended")
                --     vim.env.DOTNET_ROOT = "/usr/local/share/dotnet"
                --     vim.env.MSBuildSDKsPath = "/Applications/Unity/Hub/Editor/6000.0.43f1/Unity.app/Contents/Managed/"
                --
                --     -- Expanded on_attach function with proper keybindings
                --     local on_attach = function(client, bufnr)
                --         print("✅ OmniSharp LSP attached to buffer " .. bufnr)
                --
                --         -- Define keybindings
                --         local opts = { noremap = true, silent = true, buffer = bufnr }
                --
                --         -- Go to definition
                --         vim.keymap.set("n", "gd", function()
                --             require("omnisharp_extended").telescope_lsp_definitions()
                --         end, opts)
                --
                --         -- Documentation with Shift+K
                --         vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                --
                --         -- Other useful mappings
                --         vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                --         vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                --         vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                --         vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                --
                --         -- Set omnisharp as the formatter for C# files
                --         if client.server_capabilities.documentFormattingProvider then
                --             vim.api.nvim_create_autocmd("BufWritePre", {
                --                 pattern = "*.cs",
                --                 callback = function()
                --                     vim.lsp.buf.format({ async = false })
                --                 end,
                --                 buffer = bufnr,
                --             })
                --         end
                --     end,
                --     lspconfig.omnisharp.setup({
                --         cmd = {
                --             "dotnet",
                --             "/Users/oliver/.local/bin/omnisharp/OmniSharp.dll",
                --             "--languageserver",
                --             "--hostPID",
                --             tostring(vim.fn.getpid()),
                --             "-z", -- Enable better Unity support
                --             -- "--encoding", "utf-8",
                --             -- "--debug" -- Add debug output
                --         },
                --         -- Expanded root_dir pattern to handle Unity projects
                --         root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", "Assets", "ProjectSettings",
                --             "UnityPackageManager"),
                --         capabilities = require("cmp_nvim_lsp").default_capabilities(),
                --         handlers = {
                --             ["textDocument/definition"] = omnisharp_extended.handler,
                --             ["textDocument/references"] = omnisharp_extended.handler,
                --         },
                --         on_attach = on_attach,
                --         -- Unity-specific settings
                --         enable_ms_build_load_projects_on_demand = true,
                --         enable_roslyn_analyzers = true,
                --         organize_imports_on_format = true,
                --         enable_import_completion = true,
                --         settings = {
                --             FormattingOptions = {
                --                 EnableEditorConfigSupport = true,
                --                 OrganizeImports = true,
                --                 NewLine = "\n", -- Ensure consistent line endings
                --             },
                --             RoslynExtensionsOptions = {
                --                 EnableAnalyzersSupport = true,
                --                 EnableImportCompletion = true,
                --                 AnalyzeOpenDocumentsOnly = false, -- Changed to false to analyze referenced files too
                --             },
                --             MsBuild = {
                --                 LoadProjectsOnDemand = true,
                --                 UseLegacySdkResolver = true,
                --                 EnableAssemblyAttributeDocumentation = true, -- For better documentation
                --             },
                --             Sdk = {
                --                 IncludePrereleases = true,
                --             },
                --             FileOptions = {
                --                 SystemExcludeSearchPatterns = { "**/node_modules/**/*", "**/bin/**/*", "**/obj/**/*" },
                --                 ExcludeSearchPatterns = { "**/.git/**/*" },
                --             },
                --             ReferenceResolutionOptions = {
                --                 -- Add references to Unity assemblies
                --                 PreferredSourceRoots = {
                --                     "/Applications/Unity/Hub/Editor/6000.0.43f1/Unity.app/Contents/Managed/",
                --                     "/Users/oliver/Library/Unity/cache/"
                --                 },
                --             },
                --         },
                --         flags = {
                --             debounce_text_changes = 150,
                --         },
                --     })
                -- end,
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
