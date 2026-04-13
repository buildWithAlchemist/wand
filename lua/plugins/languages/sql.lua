-- ============================================================================
-- SQL Language Support - vim-dadbod
-- ============================================================================
--
-- disable nvim default `sql_completion` plugin to be compatible with blink.cmp's omni
-- while still showing some keywords from the syntax autocomplete sources
vim.g.omni_sql_default_compl_type = "syntax"
vim.g.loaded_sql_completion = true

return {
  -- DadBod: SQL client
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },

  -- DadBod UI: Database UI
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    dependencies = "vim-dadbod",
    keys = {
      { "<leader>sD", "<cmd>DBUIToggle<CR>", desc = "[S]QL [D]BUI Toggle" },
    },
    init = function()
      local data_path = vim.fn.stdpath("data")

      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
      vim.g.db_ui_show_database_icon = true
      vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
      vim.g.db_ui_use_nerd_fonts = true
      vim.g.db_ui_use_nvim_notify = true

      -- NOTE: The default behavior of auto-execution of queries on save is disabled
      -- this is useful when you have a big query that you don't want to run every time
      -- you save the file running those queries can crash neovim to run use the
      -- default keymap: <leader>S
      vim.g.db_ui_execute_on_save = false
    end,
    config = function()
      -- Override 'q' to close window in DBUI buffers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dbui",
        callback = function()
          vim.keymap.set("n", "q", ":close<CR>", { buffer = true, silent = true, noremap = true })
        end,
      })
    end,
  },

  -- DadBod completion: SQL completion
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod" },
    ft = { "sql", "mysql", "plsql" },
  },
}
