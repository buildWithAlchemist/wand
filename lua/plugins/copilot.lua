-- ============================================================================
-- Copilot - GitHub Copilot
-- ============================================================================

return {
  {
    "zbirenbaum/copilot.lua",
    dependencies = {
      "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    },
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = function()
      if vim.fn.executable("node") ~= 1 then
        return false
      end

      local version = vim.fn.systemlist({ "node", "--version" })[1] or ""
      local major = tonumber(version:match("^v(%d+)"))
      return major ~= nil and major > 20
    end,
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = false, -- Disable default accept mapping
          },
        },
      })
    end,
  },
}
