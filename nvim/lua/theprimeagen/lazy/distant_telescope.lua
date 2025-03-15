
-- Ensure Telescope and Distant are required
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local distant = require('distant')

-- Define the function to find remote files
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

-- Set a keymap to trigger the function
vim.api.nvim_set_keymap('n', '<leader>rf', '<cmd>lua require(\"theprimeagen.lazy.distant_telescope\").remote_find_files()<CR>', { noremap = true, silent = true })

-- Return the function so it can be required in other files
return {
    remote_find_files = remote_find_files
}

