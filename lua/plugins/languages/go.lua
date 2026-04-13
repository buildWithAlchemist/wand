-- ============================================================================
-- Go Language Support
-- ============================================================================

return {
  -- Go tools
  {
    "ray-x/go.nvim",
    ft = { "go", "gomod" },
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup({
        go = "go",
        goimports = "gopls",
        fillstruct = "gopls",
        gofmt = "gofmt",
        max_line_len = 120,
        tag_transform = false,
        test_dir = "",
        comment_placeholder = "   ",
        lsp_cfg = false, -- We handle LSP in lsp.lua
        lsp_gofumpt = true,
        lsp_on_attach = false,
        dap_debug = false,
        textobjects = true,
        lsp_inlay_hints = {
          enable = false,
        },
      })

    end,
    event = { "CmdlineEnter" },
    build = ':lua require("go.install").update_all_sync()',
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    config = function()
      require("dap-go").setup()
    end,
  },
  -- neotest-golang is listed as a neotest dependency in testing.lua
}
