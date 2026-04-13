-- ============================================================================
-- Utility Functions
-- ============================================================================

local M = {}

-- Check if a command exists
M.command_exists = function(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Check if a file exists
M.file_exists = function(path)
  return vim.fn.filereadable(path) == 1
end

-- Get Neovim version
M.get_nvim_version = function()
  local version = vim.version()
  return version.major, version.minor, version.patch
end

-- Check if Neovim version meets requirement
M.check_nvim_version = function(required_major, required_minor)
  local major, minor, _ = M.get_nvim_version()
  return major > required_major or (major == required_major and minor >= required_minor)
end

-- Check if running in a terminal that supports images
M.supports_images = function()
  local term = vim.env.TERM
  return term and (term:match("kitty") or term:match("wezterm"))
end

return M
