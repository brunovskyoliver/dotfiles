-- 📂lua/📂configs/🌑mason-lsp.lua
local status, masonlsp = pcall(require, "mason-lspconfig")

if not status then
    return
end

masonlsp.setup({
    automatic_installation = true,
    ensure_installed = {
        "cssls",
        "eslint",
        "html",
        "jsonls",
        "pyright",
        "tailwindcss",
    },
})
