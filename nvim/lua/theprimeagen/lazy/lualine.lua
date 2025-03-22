return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        -- Add the spotify plugin here so it’s loaded before we configure lualine
        "spinalshock/spotify.nvim",
    },
    config = function()
        -- Your base lualine config
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

        -- Try to load the spotify.nvim’s statusline method
        local ok, spotify_commands = pcall(require, "spotify.commands")
        if ok and spotify_commands and spotify_commands.statusline then
            -- Insert the Spotify status function into lualine_y (or whichever section you prefer)
            table.insert(lualine_opts.sections.lualine_y, spotify_commands.statusline)
        end

        require("lualine").setup(lualine_opts)
    end
}
