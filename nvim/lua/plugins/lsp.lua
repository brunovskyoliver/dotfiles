-- Mason only installs binaries; servers are configured with the native
-- vim.lsp API using the configs that ship with nvim-lspconfig.
local tools = {
    "lua-language-server", "rust-analyzer", "gopls", "basedpyright", "ruff", "clangd",
    "html-lsp", "css-lsp", "json-lsp", "emmet-language-server", "yaml-language-server",
    "gh-actions-language-server", "bash-language-server", "marksman", "roslyn-language-server",
    "stylua", "goimports", "csharpier", "prettier", "xmlformatter", "shfmt",
    "delve", "debugpy", "codelldb", "netcoredbg",
}

local servers = {
    "lua_ls", "rust_analyzer", "gopls", "basedpyright", "ruff", "clangd", "html", "cssls",
    "jsonls", "emmet_language_server", "yamlls", "gh_actions_ls", "bashls", "marksman",
    "texlab", "roslyn_ls",
}

local function install_missing()
    local registry = require("mason-registry")
    registry.refresh(function()
        for _, name in ipairs(tools) do
            local ok, pkg = pcall(registry.get_package, name)
            if ok and not pkg:is_installed() then
                pkg:install()
            end
        end
    end)
end

return {
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        opts = {},
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp", "j-hui/fidget.nvim" },
        config = function()
            require("mason").setup()
            install_missing()
            require("fidget").setup({})

            vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
                    },
                },
            })

            -- rust-analyzer is the biggest memory user. Skip indexing every
            -- dependency at startup and keep fewer parsed files cached.
            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        cachePriming = { enable = false },
                        lru = { capacity = 64 },
                        files = { excludeDirs = { "target", "node_modules", ".git" } },
                    },
                },
            })

            vim.lsp.config("gopls", {
                settings = { gopls = { usePlaceholders = false } },
            })

            vim.lsp.config("basedpyright", {
                settings = {
                    basedpyright = {
                        disableOrganizeImports = true, -- ruff does this
                        analysis = { typeCheckingMode = "standard" },
                    },
                },
            })

            vim.lsp.config("clangd", {
                cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
            })

            vim.lsp.config("html", { filetypes = { "html", "templ" } })

            vim.lsp.config("yamlls", {
                settings = {
                    redhat = { telemetry = { enabled = false } },
                    yaml = { schemaStore = { enable = true } },
                },
            })

            vim.lsp.config("roslyn_ls", {
                cmd = {
                    "roslyn-language-server",
                    "--logLevel", "Warning",
                    "--extensionLogDirectory", vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
                    "--stdio",
                },
                settings = {
                    ["csharp|completion"] = {
                        dotnet_show_completion_items_from_unimported_namespaces = true,
                    },
                },
            })

            local latex = require("config.latex")
            local use_latexmk = vim.fn.executable("latexmk") == 1
            vim.lsp.config("texlab", {
                root_dir = function(buf, on_dir)
                    on_dir(latex.project_root(buf))
                end,
                before_init = function(_, config)
                    local dir = latex.build_directory(config.root_dir)
                    local build = config.settings.texlab.build
                    build.auxDirectory, build.logDirectory, build.pdfDirectory = dir, dir, dir
                    build.args = use_latexmk
                        and { "-pdf", "-interaction=nonstopmode", "-synctex=1", "-outdir=" .. dir, "%f" }
                        or { "--keep-logs", "--keep-intermediates", "--synctex", "--outdir", dir, "%f" }
                end,
                settings = {
                    texlab = {
                        build = {
                            executable = use_latexmk and "latexmk" or "tectonic",
                            onSave = false, -- VimTeX owns compilation.
                        },
                        chktex = { onOpenAndSave = false, onEdit = false },
                        diagnosticsDelay = 500,
                    },
                },
            })

            vim.lsp.enable(servers)

            -- basedpyright answers hover for Python; ruff's is redundant.
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(e)
                    local client = vim.lsp.get_client_by_id(e.data.client_id)
                    if client and client.name == "ruff" then
                        client.server_capabilities.hoverProvider = false
                    end
                end,
            })

            vim.diagnostic.config({ float = { source = true, header = "", prefix = "" } })
        end,
    },
    { "j-hui/fidget.nvim" },
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            { "<leader>f", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "Format" },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_organize_imports", "ruff_format" },
                go = { "goimports", "gofmt" },
                rust = { "rustfmt" },
                cs = { "csharpier" },
                c = { "clang_format" },
                cpp = { "clang_format" },
                html = { "prettier" },
                css = { "prettier" },
                json = { "prettier" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                xml = { "xmlformatter" },
                sh = { "shfmt" },
                ["_"] = { "trim_whitespace" },
            },
            format_on_save = { timeout_ms = 1000, lsp_format = "never" },
        },
    },
}
