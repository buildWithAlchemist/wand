-- ============================================================================
-- Workflow Enhancements - Yanky, Hardtime, Pomodoro, Auto-save
-- ============================================================================
---
--- This module configures plugins that enhance the Neovim workflow and productivity.
--- It includes:
--- - Yank history management (Yanky)
--- - Habit formation tools (Hardtime)
--- - Pomodoro timer for focus sessions
--- - Auto-save functionality
--- - Mini plugins for various enhancements
---
--- These tools help maintain focus, prevent bad habits, and automate repetitive tasks.
---
---@module plugins.workflow

return {
  -- Yanky: Yank history
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "y",     "<Plug>(YankyYank)",                      mode = { "n", "x" },                           desc = "Yank text" },
      { "p",     "<Plug>(YankyPutAfter)",                  mode = { "n", "x" },                           desc = "Put yanked text after cursor" },
      { "P",     "<Plug>(YankyPutBefore)",                 mode = { "n", "x" },                           desc = "Put yanked text before cursor" },
      { "gp",    "<Plug>(YankyGPutAfter)",                 mode = { "n", "x" },                           desc = "Put yanked text after selection" },
      { "gP",    "<Plug>(YankyGPutBefore)",                mode = { "n", "x" },                           desc = "Put yanked text before selection" },
      { "<c-n>", "<Plug>(YankyCycleForward)",              desc = "Cycle forward through yank history" },
      { "<c-p>", "<Plug>(YankyCycleBackward)",             desc = "Cycle backward through yank history" },
      { "]p",    "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)" },
      { "[p",    "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)" },
      { "]P",    "<Plug>(YankyPutIndentAfterLinewise)",    desc = "Put indented after cursor (linewise)" },
      { "[P",    "<Plug>(YankyPutIndentBeforeLinewise)",   desc = "Put indented before cursor (linewise)" },
      { ">p",    "<Plug>(YankyPutIndentAfterShiftRight)",  desc = "Put and indent right" },
      { "<p",    "<Plug>(YankyPutIndentAfterShiftLeft)",   desc = "Put and indent left" },
      { ">P",    "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
      { "<P",    "<Plug>(YankyPutIndentBeforeShiftLeft)",  desc = "Put before and indent left" },
      { "=p",    "<Plug>(YankyPutAfterFilter)",            desc = "Put after applying a filter" },
      { "=P",    "<Plug>(YankyPutBeforeFilter)",           desc = "Put before applying a filter" },
    },
    config = function()
      require("yanky").setup({
        ring = {
          history_length = 100,
          storage = "shada",
          sync_with_numbered_registers = true,
          cancel_event = "update",
        },
        picker = {
          select = {
            action = nil,
          },
          telescope = {
            mappings = nil,
          },
        },
        system_clipboard = {
          sync_with_ring = true,
        },
        highlight = {
          on_put = true,
          on_yank = true,
          timer = 500,
        },
      })
    end,
  },

  -- Hardtime: Prevent inefficient movement habits
  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    opts = {
      enabled = true,
      disable_mouse = false,
    },
  },

  -- Mini.pairs: Lightweight auto-pairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    config = function()
      require("mini.pairs").setup({
        modes = { insert = true, command = false, terminal = false },
        mappings = {
          ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
          ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
          ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },
          [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
          ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
          ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
          ['"'] = { action = "closeopen", pair = '""', neigh_pattern = "[^\\].", register = { cr = false } },
          ["'"] = { action = "closeopen", pair = "''", neigh_pattern = "[^%a\\].", register = { cr = false } },
          ["`"] = { action = "closeopen", pair = "``", neigh_pattern = "[^\\].", register = { cr = false } },
        },
      })
    end,
  },

  -- Mini.ai: Enhanced text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({
        n_lines = 500,
        custom_textobjects = {
          o = require("mini.ai").gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</.*>.$" }, -- tags
          d = { "%f[%d]%d+" },                                              -- digits
          e = {                                                             -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
          },
          u = require("mini.ai").gen_spec.function_call(),                           -- u for "Usage"
          U = require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          g = function(ai_type)                                                      -- g for whole buffer
            local start_line, end_line = 1, vim.fn.line("$")
            if ai_type == "i" then
              while start_line < end_line and vim.fn.getline(start_line):match("^%s*$") do
                start_line = start_line + 1
              end
              while end_line > start_line and vim.fn.getline(end_line):match("^%s*$") do
                end_line = end_line - 1
              end
            end
            local to_col = math.max(vim.fn.getline(end_line):len(), 1)
            return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
          end,
        },
      })
    end,
  },

  -- Mini.icons: Icon provider for which-key and other plugins
  {
    "echasnovski/mini.icons",
    event = "VeryLazy",
    config = function()
      require("mini.icons").setup({})
    end,
  },

  -- mini.animate and mini.indentscope replaced by snacks.animate,
  -- snacks.scroll, and snacks.indent (see core.lua)

  -- Todo comments: Highlight and search TODO, FIXME, etc.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous Todo",
      },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "[F]ind [T]odos" },
      {
        "<leader>ct",
        function()
          vim.cmd("normal! OTODO: ")
          vim.cmd("startinsert!")
        end,
        desc = "[C]ode Add [T]ODO above",
      },
      {
        "<leader>cf",
        function()
          vim.cmd("normal! OFIXME: ")
          vim.cmd("startinsert!")
        end,
        desc = "[C]ode Add [F]IXME above",
      },
      {
        "<leader>cn",
        function()
          vim.cmd("normal! ONOTE: ")
          vim.cmd("startinsert!")
        end,
        desc = "[C]ode Add [N]OTE above",
      },
    },
    config = function()
      require("todo-comments").setup()
    end,
  },

  -- Trouble: Better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "[C]ode [S]ymbols" },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "[C]ode [L]SP Definitions/References",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",  desc = "Quickfix List" },
    },
    opts = {},
  },

  -- Auto-save: Save on idle and focus loss
  {
    "okuuva/auto-save.nvim",
    event = "VeryLazy",
    config = function()
      require("auto-save").setup({
        enabled = true,
        trigger_events = { "InsertLeave", "TextChanged" },
        condition = function(buf)
          return not vim.b[buf].skip_save_hooks
        end,
      })
    end,
  },

  -- Grug-far: Search and replace across files
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end,                                                     desc = "[S]earch [R]eplace" },
      { "<leader>sR", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "[S]earch [R]eplace (word)" },
      { "<leader>sf", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end,        desc = "[S]earch Replace in [F]ile" },
    },
    config = function()
      require("grug-far").setup({})
    end,
  },

  -- Undotree: Visualize undo history
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "[U]ndo Tree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 30
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- UFO: Better fold management
  {
    "kevinhwang91/nvim-ufo",
    event = "BufReadPre",
    dependencies = { "kevinhwang91/promise-async" },
    keys = {
      { "zR", function() require("ufo").openAllFolds() end,         desc = "Open all folds" },
      { "zM", function() require("ufo").closeAllFolds() end,        desc = "Close all folds" },
      { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds by level" },
      { "zm", function() require("ufo").closeFoldsWith() end,       desc = "Close folds by level" },
    },
    config = function()
      require("ufo").setup({
        provider_selector = function()
          return { "treesitter", "indent" }
        end,
      })
    end,
  },

  -- Kulala: HTTP client for .http files
  {
    "mistweaverco/kulala.nvim",
    ft = "http",
    keys = {
      { "<localleader>r", function() require("kulala").run() end,              ft = "http", desc = "Run HTTP request" },
      { "<localleader>a", function() require("kulala").run_all() end,          ft = "http", desc = "Run all HTTP requests" },
      { "<localleader>e", function() require("kulala").set_selected_env() end, ft = "http", desc = "Select HTTP environment" },
    },
    config = function()
      require("kulala").setup({})
    end,
  },
}
