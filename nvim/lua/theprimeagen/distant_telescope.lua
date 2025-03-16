
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
-- Function to get the remote IP from /tmp/last_ip
local function get_remote_ip()
    local ip_file = "/tmp/last_ip"
    local file = io.open(ip_file, "r")
    if not file then
        vim.notify("Could not read remote IP from " .. ip_file, vim.log.levels.ERROR)
        return nil
    end
    local ip = file:read("*all"):gsub("\n", "")
    file:close()
    return ip
end
-- Function to fetch remote files using SSH and Plenary
local function get_remote_files()
    local user = "brunovsky"
    local host = get_remote_ip()
    if not host then return {} end
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
    if not results or #results == 0 then
        vim.notify("No remote files found!", vim.log.levels.WARN)
        return
    end
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
                -- Close the telescope picker first to avoid buffer conflicts
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()
                if not selection or not selection.value then
                    vim.notify("Invalid file selection!", vim.log.levels.ERROR)
                    return
                end

                -- Ensure the file path is properly formatted for :DistantOpen
                local remote_path = selection.value
                remote_path = remote_path:gsub("//", "/") -- Remove double slashes

                -- Use vim.schedule to delay the execution slightly
                vim.schedule(function()
                    -- Use the Distant API directly instead of vim.cmd
                    local success, err = pcall(function()
                        -- Check if the distant connection is active
                        if distant.session and distant.session.active then
                            -- Get the host from the IP
                            local host = get_remote_ip()
                            if not host then
                                vim.notify("Failed to get remote IP", vim.log.levels.ERROR)
                                return
                            end

                            -- Use the Distant API directly to open the file
                            distant.editor.open({
                                bufnr = -1, -- Let distant create a new buffer
                                destination = {
                                    path = remote_path,
                                    host = host
                                }
                            })
                        else
                            vim.notify("Distant session is not active", vim.log.levels.ERROR)
                        end
                    end)

                    if not success then
                        vim.notify("Failed to open file with Distant API: " .. tostring(err), vim.log.levels.ERROR)
                    end
                end)
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
