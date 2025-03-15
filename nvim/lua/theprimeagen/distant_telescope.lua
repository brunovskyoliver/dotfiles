
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

    -- Perform remote search using DistantSearch asynchronously
    vim.fn.jobstart({
        "distant", "search", search_pattern, "path=" .. remote_path, "target=" .. search_target, "limit=" .. search_limit
    }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                for _, line in ipairs(data) do
                    table.insert(results, line)
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
        end,
        on_stderr = function(_, data)
            if data then
                vim.notify("DistantSearch error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
            end
        end
    })
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M

