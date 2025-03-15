
-- In file: lua/distant_telescope.lua
local M = {}

-- Ensure Telescope and Distant are properly loaded
local has_telescope, telescope = pcall(require, 'telescope')
local has_distant, distant = pcall(require, 'distant')

if not has_telescope or not has_distant then
    return M
end

local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')

-- Function to search remote files using :DistantShell and open with :DistantOpen
function M.find_remote_files(opts)
    opts = opts or {}
    local remote_path = opts.path or '.'
    local search_pattern = opts.pattern or '' -- Default pattern to find all files
    local results = {}

    local picker = pickers.new(opts, {
        prompt_title = 'Remote File Search',
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            local open_file = function()
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.cmd(string.format(':DistantOpen %s', selection.value))
                end
            end

            actions.select_default:replace(open_file)
            return true
        end
    })

    picker:find()

    -- Ensure distant is available before proceeding
    if not distant then
        vim.notify("Distant.nvim is not loaded!", vim.log.levels.ERROR)
        return
    end

    -- Perform remote search using :DistantShell find
    local output = vim.fn.systemlist(string.format(":DistantShell find %s -type f", remote_path))

    if vim.v.shell_error ~= 0 then
        vim.notify("DistantShell error: " .. table.concat(output, "\n"), vim.log.levels.ERROR)
        return
    end

    for _, line in ipairs(output) do
        if line ~= "" then
            table.insert(results, line)
        end
    end

    picker:refresh(finders.new_table {
        results = results,
        entry_maker = function(entry)
            return {
                value = entry,
                display = entry,
                ordinal = entry,
            }
        end
    })
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M
