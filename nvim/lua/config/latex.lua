local M = {}
local compile_on_save = {}

function M.build_directory(root)
    local path = vim.fs.normalize(vim.fn.resolve(vim.fn.fnamemodify(root, ":p")))
    local directory = vim.fn.stdpath("cache") .. "/latex/" .. vim.fn.sha256(path)
    vim.fn.mkdir(directory, "p")
    return directory
end

function M.project_root(buf)
    local state = vim.b[buf].vimtex
    return state and state.root or vim.fs.dirname(vim.api.nvim_buf_get_name(buf))
end

function M.setup()
    local snippets_added = false

    local group = vim.api.nvim_create_augroup("LatexReports", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "tex",
        callback = function(event)
            if not snippets_added then
                require("luasnip").add_snippets("tex", require("snippets.tex"))
                snippets_added = true
            end
            vim.opt_local.spell = true
            vim.opt_local.spelllang = "en"
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.breakindent = true
            vim.opt_local.textwidth = 0
            vim.opt_local.conceallevel = 0
            vim.opt_local.shiftwidth = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.formatoptions:remove({ "t", "a" })
            vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { buffer = event.buf, expr = true })
            vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { buffer = event.buf, expr = true })
            vim.keymap.set("n", "<localleader>la", function()
                local project = vim.b.vimtex.tex
                compile_on_save[project] = compile_on_save[project] == false
                vim.notify("LaTeX compile on save: " .. (compile_on_save[project] and "on" or "off"))
            end, { buffer = event.buf, desc = "Toggle LaTeX compilation on save" })
            vim.keymap.set("n", "<localleader>lh", "<Cmd>help latex-reports<CR>",
                { buffer = event.buf, desc = "LaTeX workflow help" })
        end,
    })

    -- Tectonic has no watch mode. Rebuild open projects after saving a source
    -- or bibliography; latexmk already watches dependencies itself.
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        pattern = { "*.tex", "*.bib" },
        callback = function(event)
            local saved = vim.api.nvim_buf_get_name(event.buf)
            local rebuilt = {}
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                local state = vim.b[buf].vimtex
                if vim.api.nvim_buf_is_loaded(buf) and state and state.compiler
                    and state.compiler.name == "tectonic"
                    and compile_on_save[state.tex] ~= false
                    and not rebuilt[state.tex]
                    and (buf == event.buf or vim.startswith(saved, state.root .. "/")) then
                    rebuilt[state.tex] = true
                    vim.api.nvim_buf_call(buf, function()
                        vim.cmd("VimtexCompileSS")
                    end)
                end
            end
        end,
    })
end

return M
