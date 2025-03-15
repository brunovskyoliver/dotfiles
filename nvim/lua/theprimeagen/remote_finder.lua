
-- Ensure Telescope and Distant are properly loaded
local ok_telescope, telescope = pcall(require, 'telescope')
local ok_distant, distant = pcall(require, 'distant')

if not ok_telescope then
    vim.notify("Telescope is not installed or failed to load!", vim.log.levels.ERROR)
    return
end
if not ok_distant then
    vim.notify("Distant.nvim is not installed or failed to load!", vim.log.levels.ERROR)
    return
end

-- Register a Telescope extension
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local config = require('telescope.config')
local telescope_builtin = require('telescope.builtin')

-- Define the extension
local distant_extension = {}

distant_extension.remote_find_files = function(opts)
    opts = opts or {}
    local remote_path = opts.path or '.'

    -- Use existing telescope builtin functionality
    telescope_builtin.find_files({
        prompt_title = 'Remote Files',
        cwd = remote_path,
        find_command = function(path)
            local results = {}
            -- Use the synchronous API if available
            if distant.system and distant.system.exec then
                local output = distant.system.exec('find ' .. path .. ' -type f', { capture_output = true })
                if output and output.stdout then
                    for file in string.gmatch(output.stdout, "[^\r\n]+") do
                        table.insert(results, file)
                    end
                end
            else
                -- Fallback to a basic list if available
                vim.notify("Using simplified remote file listing", vim.log.levels.WARN)
                distant.core.connect(function()
                    -- This will depend on your specific distant API
                    -- You might need to adjust this code based on distant.nvim's API
                    distant.files.list({ path = path }, function(err, files)
                        if err then
                            vim.notify("Error listing remote files", vim.log.levels.ERROR)
                            return
                        end
                        for _, file in ipairs(files) do
                            if file.type == "file" then
                                table.insert(results, file.path)
                            end
                        end
                    end)
                end)
            end
            return results
        end,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    if distant.edit then
                        distant.edit(selection.value)
                    else
                        vim.cmd('edit ' .. selection.value)
                    end
                end
            end)
            return true
        end,
    })
end

-- Register the extension with Telescope
return telescope.register_extension({
    exports = {
        remote_files = distant_extension.remote_find_files
    }
})
