local panes = { "repl", "stacks", "scopes", "console", "watches", "breakpoints" }

local function toggle_ui(name)
    return function()
        local dapui = require("dapui")
        dapui.close()
        dapui.toggle(vim.fn.index(panes, name) + 1)
    end
end

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "jay-babu/mason-nvim-dap.nvim",
            "mason-org/mason.nvim",
        },
        keys = {
            { "<F8>", function() require("dap").continue() end, desc = "Debug: Continue" },
            { "<F10>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
            { "<F11>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
            { "<F12>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
            { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
            { "<leader>B", function()
                require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
            end, desc = "Debug: Conditional Breakpoint" },
            { "<leader>dr", toggle_ui("repl"), desc = "Debug: repl" },
            { "<leader>ds", toggle_ui("stacks"), desc = "Debug: stacks" },
            { "<leader>dw", toggle_ui("watches"), desc = "Debug: watches" },
            { "<leader>db", toggle_ui("breakpoints"), desc = "Debug: breakpoints" },
            { "<leader>dS", toggle_ui("scopes"), desc = "Debug: scopes" },
            { "<leader>dc", toggle_ui("console"), desc = "Debug: console" },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")
            require("mason").setup()

            local layouts = {}
            for _, name in ipairs(panes) do
                table.insert(layouts, { elements = { { id = name } }, size = 40, position = "right" })
            end
            dapui.setup({ layouts = layouts })

            dap.listeners.before.event_terminated.dapui = dapui.close
            dap.listeners.before.event_exited.dapui = dapui.close

            local function file_args(name)
                return {
                    type = "delve", name = name, request = "launch", program = "${file}",
                    outputMode = "remote",
                    args = function() return vim.split(vim.fn.input("args> "), " ") end,
                }
            end
            require("mason-nvim-dap").setup({
                handlers = {
                    function(config)
                        require("mason-nvim-dap").default_setup(config)
                    end,
                    python = function(config)
                        config.configurations = config.configurations or {}
                        table.insert(config.configurations, {
                            type = "python", request = "launch", name = "Python: current file",
                            program = "${file}", console = "internalConsole",
                        })
                        require("mason-nvim-dap").default_setup(config)
                    end,
                    delve = function(config)
                        table.insert(config.configurations, 1, file_args("file"))
                        table.insert(config.configurations, 1, file_args("file args"))
                        require("mason-nvim-dap").default_setup(config)
                    end,
                },
            })
        end,
    },
}
