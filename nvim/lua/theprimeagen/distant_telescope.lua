
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

    -- Use the simplest approach possible
    -- This is a synchronous placeholder. For Distant's actual API, you'll need to replace this
    local results = {}

    -- Create a picker that waits for results
    local picker = pickers.new(opts, {
        prompt_title = 'Remote Files',
        finder = finders.new_table {
            results = {"Loading remote files..."},
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

    -- Start the picker
    picker:find()

    -- Now fetch the files (this should be adjusted to distant.nvim's actual API)
    distant.core.connect(function()
        distant.files.list({ path = remote_path }, function(err, files)
            if err then
                vim.notify("Error listing remote files: " .. vim.inspect(err), vim.log.levels.ERROR)
                return
            end

            -- Get the results
            results = {}
            for _, file in ipairs(files) do
                table.insert(results, file.path)
            end

            -- Update the picker with actual results
            picker.finder = finders.new_table {
                results = results,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry,
                        ordinal = entry,
                    }
                end
            }

            -- Refresh the picker
            picker:refresh()
        end)
    end)
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M
