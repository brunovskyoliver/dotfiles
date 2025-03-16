
-- In file: lua/distant_telescope.lua
local M = {}

-- Ensure Telescope, Distant, and Plenary are properly loaded
local has_telescope, telescope = pcall(require, 'telescope')
local has_distant, distant = pcall(require, 'distant')
local has_plenary, sys = pcall(require, 'plenary.job')

if not has_telescope or not has_distant or not has_plenary then
    return M
end

local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')

-- SSH connection details (update as needed)
local user = "your_username"
local host = "your_remote_host"
local remote_command = "ssh"
local remote_args = { user .. "@" .. host, "find", "/", "-type", "f" }

-- Function to fetch remote files using SSH and Plenary
local function get_remote_files()
    local job = sys:new({
        command = remote_command,
        args = remote_args,
    })
    job:start()
    job:join()
    return job:result()
end

-- Function to create a remote file finder
function M.find_remote_files(opts)
    opts = opts or {}

    local results = get_remote_files()

    pickers.new(opts, {
        prompt_title = "Remote Files",
        finder = finders.new_table({
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry,
                    ordinal = entry,
                }
            end
        }),
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
    }):find()
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M

