
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

-- Function to search remote files using DistantSearch
function M.find_remote_files(opts)
    opts = opts or {}
    local remote_path = opts.path or '.'
    local search_pattern = opts.pattern or '.*' -- Default pattern to match everything
    local search_target = opts.target or 'contents' -- Default to searching file contents
    local search_limit = opts.limit or 100 -- Default limit to 100 results

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
    })

    picker:find()

    -- Ensure distant is available before proceeding
    if not distant then
        vim.notify("Distant.nvim is not loaded!", vim.log.levels.ERROR)
        return
    end

    -- Check if Distant has an active connection
    distant.api.info(function(err, info)
        if err or not info then
            vim.notify("Distant is not connected to any remote server!", vim.log.levels.ERROR)
            return
        end

        -- Perform remote search using :DistantSearch
        vim.cmd(string.format(":DistantSearch %s path=%s target=%s limit=%d",
            search_pattern, remote_path, search_target, search_limit))

        -- Capture results dynamically using Vim command output
        local output = vim.fn.execute("redir => g:search_results | silent! messages | redir END")
        for line in output:gmatch("[^\r\n]+") do
            table.insert(results, line)
        end

        -- Refresh picker with new results
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
    end)
end

-- Setup function
function M.setup()
    -- Ensure distant.nvim is initialized
    distant.setup({
        ['*'] = {
            mode = 'ssh',
        }
    })
end

return M

