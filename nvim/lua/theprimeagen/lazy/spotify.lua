-- lazy
return {
    'spinalshock/spotify.nvim',
    dependencies = {
        { 'folke/noice.nvim' },          -- optional
        { 'folke/which-key.nvim' },      -- optional
        { 'nvim-lualine/lualine.nvim' }, -- optional
    },
    opts = {                             -- Default configuration options (optional for user overrides)
        keymaps = {
            { name = 'play_pause',     mode = 'n', '<leader>mp', ':SpotifyPlayPause<CR>',     desc = 'Play/Pause Spotify' },
            { name = 'next',           mode = 'n', '<leader>mn', ':<C-U>SpotifyNext<CR>',     desc = 'Next Spotify Track' },
            { name = 'previous',       mode = 'n', '<leader>mb', ':<C-U>SpotifyPrev<CR>',     desc = 'Previous Spotify Track' },
            { name = 'volume_up',      mode = 'n', '<leader>+',  ':<C-U>SpotifyVolUp<CR>',    desc = 'Increase Spotify Volume' },
            { name = 'volume_down',    mode = 'n', '<leader>-',  ':<C-U>SpotifyVolDown<CR>',  desc = 'Decrease Spotify Volume' },
            { name = 'shuffle_toggle', mode = 'n', '<leader>ms', ':SpotifyToggleShuffle<CR>', desc = 'Toggle Spotify Shuffle' },
            { name = 'repeat_toggle',  mode = 'n', '<leader>mr', ':SpotifyToggleRepeat<CR>',  desc = 'Toggle Spotify Repeat' },
            { name = 'sound_volume',   mode = 'n', '<leader>mv', ':SpotifyVolume<CR>',        desc = 'Show Spotify Volume' },
            { name = 'info',           mode = 'n', '<leader>mi', ':SpotifyInfo<CR>',          desc = 'Show Spotify Info' },
            { name = 'mute_toggle',    mode = 'n', '<leader>mm', ':SpotifyToggleMute<CR>',    desc = 'Toggle Spotify Mute' },
        },
    },
    config = function(_, opts)
        require('spotify').setup(opts) -- pass user options to the plugin setup
    end,
}
