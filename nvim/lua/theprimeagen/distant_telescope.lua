
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

-- Function to list remote files
function M.find_remote_files(opts)
    opts = opts or {}
    local remote_path = opts.path or '.'

    local picker = pickers.new(opts, {
        prompt_title = 'Remote Files',
        finder = finders.new_table {
            results = {"Fetching remote files..."},
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

    -- Fetch files asynchronously from Distant
    distant.connect({}, function(err, conn)
        if err or not conn then
            vim.notify("Error connecting to distant: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
        end

        conn:send({
            type = "list",
            path = remote_path
        }, function(resp_err, result)
            if resp_err or not result then
                vim.notify("Error listing remote files: " .. vim.inspect(resp_err), vim.log.levels.ERROR)
                return
            end

            local results = {}
            for _, file in ipairs(result) do
                table.insert(results, file.path)
            end

            -- Update the picker with actual results
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
    end)
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M

