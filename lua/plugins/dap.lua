-- ============================================================================
-- DAP Configuration - Debug Adapter Protocol
-- ============================================================================

return {
  -- DAP Core
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
      "mxsdev/nvim-dap-vscode-js",
    },
    keys = {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "[D]ebug [B]reakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "[D]ebug [C]ontinue",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "[D]ebug Step [I]nto",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "[D]ebug Step [O]ver",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "[D]ebug Step [O]ut",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "[D]ebug [R]EPL",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "[D]ebug [L]ast",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "[D]ebug [T]erminate",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "[D]ebug [U]I Toggle",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- DAP UI setup
      dapui.setup({
        force_buffers = true,
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        -- Use this to override mappings for specific elements
        element_mappings = {
          -- Example:
          -- stacks = {
          --   open = "<CR>",
          --   expand = "o",
          -- }
        },
        expand_lines = true,
        -- Layouts define sections of the screen to place windows.
        -- The position can be "left", "right", "top" or "bottom".
        -- The size specifies the height/width depending on position. It can be an Int
        -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
        -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
        -- Elements are the elements shown in the layout (in order).
        -- Layouts are opened in order so that earlier layouts take priority in window sizing.
        layouts = {
          {
            elements = {
              -- Elements can be strings or table with id and size keys.
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40, -- 40 columns
            position = "left",
          },
          {
            elements = { "repl", "console" },
            size = 0.25, -- 25% of total lines
            position = "bottom",
          },
        },
        controls = {
          -- Requires Neovim nightly (or 0.8 when released)
          enabled = true,
          -- Display controls in this element
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "↻",
            terminate = "□",
          },
        },
        floating = {
          max_height = nil,  -- These can be integers or a float between 0 and 1.
          max_width = nil,   -- Floats will be treated as percentage of your screen.
          border = "single", -- Border style. Can be "single", "double" or "rounded"
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = {},
        render = {
          indent = 1,
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
        },
      })

      -- DAP Virtual Text
      require("nvim-dap-virtual-text").setup({})

      -- DAP Adapters (go and python are configured in their language files)
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
        node_path = "node",
        debugger_cmd = { "js-debug-adapter" },
        log_file_path = vim.fn.stdpath("cache") .. "/dap_vscode_js.log",
        log_file_level = vim.log.levels.DEBUG,
        log_console_level = vim.log.levels.ERROR,
      })

      -- DAP signs
      vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "🔵", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "🟡", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "🟢", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "🔶", texthl = "", linehl = "", numhl = "" })

      -- DAP listeners
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
