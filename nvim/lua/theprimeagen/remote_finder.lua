
-- Ensure Telescope and Distant are properly loaded
-- Define the function to find remote files
local function remote_find_files(opts)
    opts = opts or {}

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

    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- Check if the telescope pickers module is available
    if not telescope.pickers then
        vim.notify("Telescope pickers is nil! Ensure Telescope is properly installed.", vim.log.levels.ERROR)
        return
    end

    telescope.pickers.new(opts, {
        prompt_title = 'Remote Files',
        finder = telescope.finders.new_table {
            results = distant.files.list({ path = opts.path or '.' }),
        },
        sorter = telescope.config.values.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, _)
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

