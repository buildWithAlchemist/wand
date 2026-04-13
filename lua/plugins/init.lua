-- ============================================================================
-- Plugin Loader
-- All plugins are automatically loaded from this directory by lazy.nvim
-- ============================================================================

-- Load all plugin specs from subdirectories
local M = {}

vim.list_extend(M, require("plugins.languages.sql"))
vim.list_extend(M, require("plugins.languages.python"))
vim.list_extend(M, require("plugins.languages.go"))
vim.list_extend(M, require("plugins.languages.godot"))
vim.list_extend(M, require("plugins.languages.rust"))
vim.list_extend(M, require("plugins.languages.typescript"))
vim.list_extend(M, require("plugins.languages.markdown"))

return M
