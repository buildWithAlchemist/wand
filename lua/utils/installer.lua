-- ============================================================================
-- Installation Helper
-- ============================================================================

local M = {}
local utils = require("utils")

local setup_marker = vim.fn.stdpath("state") .. "/mad_engineer_setup_complete"

local function mark_setup_complete()
  vim.fn.mkdir(vim.fn.fnamemodify(setup_marker, ":h"), "p")
  local file = io.open(setup_marker, "w")
  if file then
    file:write(os.date("!%Y-%m-%dT%H:%M:%SZ"))
    file:close()
  end
end

local function setup_complete()
  return vim.fn.filereadable(setup_marker) == 1
end

local function run_ex_command(cmd, error_context)
  local ok, err = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify(error_context .. ": " .. err, vim.log.levels.ERROR)
  end
  return ok
end

-- Check if all requirements are met
M.check_requirements = function()
  local issues = {}

  -- Check Neovim version
  if not utils.check_nvim_version(0, 11) then
    table.insert(issues, "Neovim 0.11.0+ is required")
  end

  -- Check git
  if not utils.command_exists("git") then
    table.insert(issues, "git is required but not found")
  end

  return #issues == 0, issues
end

-- Install missing dependencies (Arch Linux specific)
M.install_arch_deps = function()
  local deps = {
    "ripgrep",
    "fd",
    "lazygit",
    "python",
    "python-pip",
    "nodejs",
    "npm",
    "go",
    "rust",
  }

  vim.notify("Installing dependencies with pacman...", vim.log.levels.INFO)
  local cmd = string.format("sudo pacman -S --needed %s", table.concat(deps, " "))
  vim.fn.system(cmd)
end

-- Install all Mason-managed tooling declared in mason-tool-installer
M.install_managed_tools = function()
  local tool_installer_ok, tool_installer = pcall(require, "mason-tool-installer")
  if not tool_installer_ok then
    vim.notify("mason-tool-installer not loaded yet", vim.log.levels.ERROR)
    return false
  end

  vim.notify("Installing Mason-managed tools...", vim.log.levels.INFO)
  local ok, err = pcall(tool_installer.check_install, false, true)
  if not ok then
    vim.notify("Failed to install Mason-managed tools: " .. err, vim.log.levels.ERROR)
  end
  return ok
end

-- Post-install setup
M.post_install = function()
  vim.notify("Running post-install setup...", vim.log.levels.INFO)

  -- Ensure lazy has synced all plugins
  local lazy_sync_ok = run_ex_command("Lazy sync", "Failed to sync plugins with lazy.nvim")
  if not lazy_sync_ok then
    vim.notify("Setup wizard left incomplete. Re-run :MadEngineerSetup after fixing the error.", vim.log.levels.WARN)
    return
  end

  -- Wait a bit for plugins to load
  vim.defer_fn(function()
    local tools_ok = M.install_managed_tools()

    -- Update treesitter parsers
    local treesitter_ok = run_ex_command("TSUpdate", "Failed to update Treesitter parsers")

    if tools_ok and treesitter_ok then
      mark_setup_complete()
      vim.notify("Installation complete! Restart Neovim.", vim.log.levels.INFO)
    else
      vim.notify("Setup wizard left incomplete. Re-run :MadEngineerSetup after fixing the error.", vim.log.levels.WARN)
    end
  end, 2000)
end

-- First-time setup wizard
M.setup_wizard = function()
  local ok, issues = M.check_requirements()

  if not ok then
    vim.notify("Requirements not met:\n" .. table.concat(issues, "\n"), vim.log.levels.ERROR)
    return
  end

  vim.notify("mad_engineer_nvim - First Time Setup", vim.log.levels.INFO)

  -- Detect OS
  local os_name = vim.uv.os_uname().sysname
  if os_name == "Linux" then
    -- Check if Arch-based
    if utils.file_exists("/etc/arch-release") then
      vim.ui.select({ "Yes", "No" }, {
        prompt = "Install dependencies with pacman?",
      }, function(choice)
        if choice == "Yes" then
          M.install_arch_deps()
        end
        M.post_install()
      end)
    else
      vim.notify("Please install dependencies manually (see INSTALL.md)", vim.log.levels.WARN)
      M.post_install()
    end
  else
    vim.notify("Please install dependencies manually (see INSTALL.md)", vim.log.levels.WARN)
    M.post_install()
  end
end

M.register_commands = function()
  vim.api.nvim_create_user_command("MadEngineerSetup", function()
    M.setup_wizard()
  end, { desc = "Run the Mad Engineer setup wizard" })
end

M.maybe_run_setup_wizard = function()
  if setup_complete() or #vim.api.nvim_list_uis() == 0 then
    return
  end

  vim.schedule(function()
    vim.notify("First launch detected. Starting Mad Engineer setup wizard...", vim.log.levels.INFO)
    M.setup_wizard()
  end)
end

return M
