return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "spinalshock/spotify.nvim",
    },
    config = function()
        -- Your existing lualine config
        local lualine_opts = {
            options = {
                theme = "gruvbox",
                section_separators = { "", "" },
                component_separators = { "", "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch" },
                lualine_c = { "filename" },
                lualine_x = { "encoding", "fileformat", "filetype" },
                -- <=== We'll prepend Spotify status to `lualine_y` below
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = { "filename" },
                lualine_x = { "location" },
                lualine_y = {},
                lualine_z = {},
            },
            extensions = { "fugitive", "nvim-tree" },
        }

        -- Attempt to require the Spotify status function
        local ok, spotify_commands = pcall(require, "spotify.commands")
        if ok and spotify_commands and spotify_commands.statusline then
            table.insert(lualine_opts.sections.lualine_x, 1, spotify_commands.statusline)
        end

        require("lualine").setup(lualine_opts)
    end
}
