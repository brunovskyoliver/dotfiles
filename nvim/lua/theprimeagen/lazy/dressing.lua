return {
    "stevearc/dressing.nvim",
    event = "VeryLazy", -- loads it lazily to speed up startup
    config = function()
        require("dressing").setup({
            input = { enabled = false },
        })
    end,
}
