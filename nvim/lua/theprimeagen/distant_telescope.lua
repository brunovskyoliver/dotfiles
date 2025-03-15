
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

-- Function to search remote files using distant:spawn_wrap and open with :DistantOpen
function M.find_remote_files(opts)
    opts = opts or {}
    local remote_path = opts.path or '.'
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

    -- Spawn the remote command asynchronously
    distant:spawn_wrap({
        cmd = { "find", remote_path, "-type", "f" },
        shell = true,
    }, function(err, wrapped_cmd)
        if err or not wrapped_cmd then
            vim.notify("Error wrapping remote command: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
        end

        -- Run the wrapped command and capture output asynchronously
        local job_id = vim.fn.jobstart(wrapped_cmd, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data then
                    for _, line in ipairs(data) do
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
            end,
            on_stderr = function(_, data)
                if data then
                    vim.notify("DistantShell error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
                end
            end
        })

        if job_id <= 0 then
            vim.notify("Failed to start remote job!", vim.log.levels.ERROR)
        end
    end)
end

-- Setup function
function M.setup()
    -- Nothing special needed here
end

return M

