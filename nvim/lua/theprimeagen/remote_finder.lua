
-- Ensure required plugins are loaded
local telescope_ok, telescope = pcall(require, 'telescope')
local distant_ok, distant = pcall(require, 'distant')

if not (telescope_ok and distant_ok) then
    return
end

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

-- Define the remote file search function
local function remote_find_files(opts)
    opts = opts or {}
    telescope.pickers.new(opts, {
        prompt_title = 'Remote Files',
        finder = telescope.finders.new_table {
            results = distant.files.list({ path = opts.path or '.' }),
        },
        sorter = telescope.config.values.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    vim.cmd('edit ' .. selection.value)
                end
            end)
            return true
        end,
    }):find()
end

return {
    remote_find_files = remote_find_files
}

