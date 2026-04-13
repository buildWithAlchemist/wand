-- ============================================================================
-- mad_engineer_nvim - Main Entry Point
-- Performance-focused Neovim config for polyglot engineers
-- Boot target: <100ms | RAM target: <100MB
-- ============================================================================

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins (required for which-key)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load core configuration
require("config")

-- Load plugins with lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
    { import = "features" },
  },
  defaults = {
    lazy = true, -- Lazy load all plugins by default for performance
  },
  rocks = {
    hererocks = false,
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "single",
  },
  checker = {
    enabled = false, -- Don't auto-check for updates (manual control)
  },
  change_detection = {
    enabled = true,
    notify = false, -- Don't notify on config changes
  },
})

require("utils.installer").register_commands()
require("utils.installer").maybe_run_setup_wizard()
