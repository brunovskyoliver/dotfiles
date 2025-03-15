
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local distant = require('distant.nvim')  -- ensure distant.nvim is required

-- Define the remote_find_files function globally or within a module

function remote_find_files(opts)
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

-- Keybinding to trigger the remote file finder
vim.api.nvim_set_keymap('n', '<leader>rf', '<cmd>lua remote_find_files()<CR>', { noremap = true, silent = true })

return {
    'chipsenkbeil/distant.nvim',
    branch = 'v0.3',
    config = function()
        distant:setup()
    end
}
