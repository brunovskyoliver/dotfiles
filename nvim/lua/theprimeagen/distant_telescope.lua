
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

-- Function to get remote connection details from Distant
local function get_distant_connection()
    local info = distant.api.info()
    if not info or not info.client then
        vim.notify("Distant is not connected!", vim.log.levels.ERROR)
        return nil, nil
    end
    return info.client.username, info.client.host
end

-- Function to fetch remote files using SSH and Plenary
local function get_remote_files()
    local user, host = get_distant_connection()
    if not user or not host then return {} end

    local job = sys:new({
        command = "ssh",
        args = { user .. "@" .. host, "find", "/", "-type", "f" },
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

