-- ============================================================================
-- Testing - Neotest
-- ============================================================================

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-plenary",
      "fredrikaverpil/neotest-golang",
      "rouge8/neotest-rust",
      "haydenmeade/neotest-jest",
      "nvim-neotest/neotest-python",
    },
    keys = {
      { "<leader>Tt", function() require("neotest").run.run() end, desc = "[T]est Run Nearest" },
      { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "[T]est Run [F]ile" },
      { "<leader>Td", function() require("neotest").run.run({ strategy = "dap", suite = false }) end, desc = "[T]est [D]ebug Nearest" },
      { "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "[T]est [S]ummary Toggle" },
      { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "[T]est [O]utput Show" },
      { "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "[T]est Output Panel" },
      { "<leader>TS", function() require("neotest").run.stop() end, desc = "[T]est [S]top" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            args = { "--log-level", "DEBUG" },
            runner = "pytest",
          }),
          require("neotest-golang")({ runner = "go" }),
          require("neotest-rust"),
          require("neotest-jest"),
          require("neotest-plenary"),
        },
        default_strategy = "integrated",
        log_level = vim.log.levels.WARN,
        consumers = {},
        icons = {
          running = "⟳",
          failed = "✗",
          passed = "✓",
          skipped = "ﰸ",
          unknown = "?",
        },
        highlights = {
          passed = "NeotestPassed",
          failed = "NeotestFailed",
          running = "NeotestRunning",
          skipped = "NeotestSkipped",
          unknown = "NeotestUnknown",
        },
        strategies = {
          integrated = {
            width = 120,
            height = 40,
          },
        },
        run = {
          enabled = true,
        },
        output_panel = {
          enabled = true,
          open = "botright split | resize 15",
        },
        state = {
          enabled = true,
        },
        watch = {
          enabled = true,
          symbol_queries = {
            go = "func Test",
            python = "def test_",
            rust = "fn test",
            javascript = "describe|it|test",
          },
        },
        discovery = {
          enabled = true,
          concurrent = true,
        },
        running = {
          concurrent = true,
        },
        status = {
          enabled = true,
          virtual_text = true,
          signs = true,
        },
        output = {
          enabled = true,
          open_on_run = "short",
        },
        quickfix = {
          enabled = false,
          open = false,
        },
        diagnostic = {
          enabled = true,
          severity = vim.diagnostic.severity.ERROR,
        },
        floating = {
          border = "single",
          max_height = nil,
          max_width = nil,
          options = {},
        },
        summary = {
          enabled = true,
          expand_errors = true,
          follow = true,
          animated = true,
          open = "botright split | resize 15",
          count = 10,
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u",
            debug = "d",
            mark = "m",
            run_marked = "R",
            debug_marked = "D",
            clear_marked = "c",
            target = "t",
            clear_target = "T",
            next_failed = "J",
            prev_failed = "K",
            next_sibling = "n",
            prev_sibling = "p",
            parent = "P",
            watch = "w",
          },
        },
      })
    end,
  },
}
