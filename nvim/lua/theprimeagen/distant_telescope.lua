
local M = {}

local has_telescope, telescope = pcall(require, 'telescope')
local has_distant, _ = pcall(require, 'distant')
local has_plenary, sys = pcall(require, 'plenary.job')
if not has_telescope or not has_distant or not has_plenary then
    return M
end

local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')

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
                actions.close(prompt_bufnr)

                local selection = action_state.get_selected_entry()
                if not selection or not selection.value then
                    vim.notify("Invalid file selection!", vim.log.levels.ERROR)
                    return
                end

                local remote_path = selection.value:gsub("//", "/")

                vim.schedule(function()
                    local success, err = pcall(function()
                        vim.cmd(('DistantOpen "%s"'):format(remote_path))
                    end)

                    if not success then
                        vim.notify("Failed to open file with :DistantOpen:\n" .. tostring(err), vim.log.levels.ERROR)
                    end
                end)
            end

            actions.select_default:replace(open_file)
            return true
        end
    }):find()
end

function M.setup()
end

return M

