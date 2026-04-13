-- ============================================================================
-- Rust Language Support
-- ============================================================================

return {
  -- Rust tools
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    config = function()
      vim.g.rustaceanvim = {
        server = {
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = true,
              cargo = {
                allFeatures = true,
              },
              procMacro = {
                enable = true,
              },
            },
          },
        },
        tools = {
          hover_actions = {
            auto_focus = true,
          },
        },
      }
    end,
  },

  -- Crates: Cargo.toml helper
  {
    "saecki/crates.nvim",
    event = { "BufReadPost Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        popup = {
          autofocus = true,
          border = "single",
        },
      })
    end,
  },
}

