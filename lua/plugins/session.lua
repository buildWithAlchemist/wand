-- ============================================================================
-- Session & Project Management
-- ============================================================================

return {
  -- Project.nvim: Project management with auto root detection
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern", "lsp" },
        patterns = {
          ".git",
          "_darcs",
          ".hg",
          ".bzr",
          ".svn",
          "Makefile",
          "package.json",
          "go.mod",
          "Cargo.toml",
        },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath("data"),
      })

      -- Telescope integration
      pcall(function()
        require("telescope").load_extension("projects")
      end)
    end,
    keys = {
      { "<leader>fp", "<cmd>Telescope projects<cr>", desc = "[F]ind [P]rojects" },
    },
  },

  -- Persistence.nvim: Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "[Q]uit [S]ession Restore",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "[Q]uit [L]ast Session Restore",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "[Q]uit [D]on't Save Session",
      },
    },
    opts = {
      dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/"),
      options = { "buffers", "curdir", "tabpages", "winsize" },
      pre_save = nil,
      save_empty = false,
    },
  },
}
