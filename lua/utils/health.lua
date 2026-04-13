-- ============================================================================
-- Health Check for mad_engineer_nvim
-- Run with :checkhealth mad_engineer
-- ============================================================================

local M = {}
local utils = require("utils")

local memory_target_mb = 100

M.check = function()
  local health = vim.health or require("health")
  local start = health.start or health.report_start
  local ok = health.ok or health.report_ok
  local warn = health.warn or health.report_warn
  local error = health.error or health.report_error
  local info = health.info or health.report_info

  start("mad_engineer_nvim")

  -- Check Neovim version
  local major, minor, patch = utils.get_nvim_version()
  local version_string = string.format("%d.%d.%d", major, minor, patch)

  if utils.check_nvim_version(0, 11) then
    ok(string.format("Neovim version: %s", version_string))
  else
    error(string.format("Neovim version %s is too old. Required: 0.11.0+", version_string))
  end

  -- Check required CLI tools
  local required_tools = {
    { "git",     "Required for lazy.nvim and version control" },
    { "rg",      "ripgrep - Required for Telescope live_grep" },
    { "fd",      "fd - Required for Telescope find_files" },
    { "lazygit", "LazyGit - Git UI" },
  }

  for _, tool in ipairs(required_tools) do
    if utils.command_exists(tool[1]) then
      ok(string.format("%s found", tool[1]))
    else
      warn(string.format("%s not found - %s", tool[1], tool[2]))
    end
  end

  -- Check language tools
  local language_tools = {
    { "python3", "Python interpreter" },
    { "node",    "Node.js runtime" },
    { "npm",     "Node.js package manager" },
    { "go",      "Go compiler" },
    { "cargo",   "Rust package manager" },
  }

  for _, tool in ipairs(language_tools) do
    if utils.command_exists(tool[1]) then
      ok(string.format("%s found", tool[1]))
    else
      info(string.format("%s not found - %s", tool[1], tool[2]))
    end
  end

  -- Check LSP servers
  local mason_registry_avail, mason_registry = pcall(require, "mason-registry")
  if mason_registry_avail then
    -- Mason registry uses package names, not lspconfig server names
    local lsp_packages = {
      "lua-language-server",
      "pyright",
      "ruff",
      "typescript-language-server",
      "gopls",
      "rust-analyzer",
      "sqlls",
      "marksman",
    }

    local installed_count = 0
    for _, pkg in ipairs(lsp_packages) do
      if mason_registry.is_installed(pkg) then
        installed_count = installed_count + 1
      end
    end

    if installed_count == #lsp_packages then
      ok(string.format("All %d LSP servers installed", #lsp_packages))
    else
      warn(string.format("%d/%d LSP servers installed", installed_count, #lsp_packages))
    end
  else
    info("Mason not yet loaded - LSP servers will be checked on first launch")
  end

  local managed_tools = {
    "black",
    "isort",
    "prettierd",
    "eslint_d",
    "markdownlint-cli2",
  }

  if mason_registry_avail then
    local installed_tools = 0
    for _, pkg in ipairs(managed_tools) do
      if mason_registry.is_installed(pkg) then
        installed_tools = installed_tools + 1
      end
    end

    if installed_tools == #managed_tools then
      ok(string.format("All %d managed formatters/linters installed", #managed_tools))
    else
      warn(string.format("%d/%d managed formatters/linters installed", installed_tools, #managed_tools))
    end
  end

  -- Check Nerd Font
  if vim.fn.has("gui_running") == 0 then
    local nf_test = vim.fn.nr2char(0xf188) -- Nerd font icon
    if nf_test ~= "" then
      ok("Nerd Font detected")
    else
      warn("Nerd Font not detected - icons may not render properly")
    end
  end

  -- Check terminal capabilities
  if vim.fn.has("termguicolors") == 1 and vim.o.termguicolors then
    ok("Terminal supports true color")
  else
    warn("Terminal may not support true color")
  end

  -- Check image support (for Jupyter)
  if utils.supports_images() then
    ok("Terminal supports image rendering (Kitty/WezTerm)")
  else
    info("Terminal does not support image rendering - Jupyter plots will not render inline")
  end

  -- Performance metrics
  local startuptime_file = vim.fn.stdpath("cache") .. "/startuptime"
  if utils.file_exists(startuptime_file) then
    local handle = io.open(startuptime_file, "r")
    if handle then
      local content = handle:read("*a")
      handle:close()
      local time = tonumber(content:match("(%d+%.%d+)"))
      if time then
        if time < 100 then
          ok(string.format("Startup time: %.2fms (target: <100ms)", time))
        else
          warn(string.format("Startup time: %.2fms (target: <100ms)", time))
        end
      end
    end
  else
    info("Startup time: Run 'nvim --startuptime /tmp/startup.log' to measure")
  end

  -- Check plugin count
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugin_count = #vim.tbl_keys(lazy.plugins())
    info(string.format("Loaded plugins: %d", plugin_count))
  end

  -- Check for Lua syntax errors in config files
  local config_files = {
    "lua/config/options.lua",
    "lua/config/autocmds.lua",
    "lua/config/keymaps.lua",
    "lua/config/languages.lua",
    "lua/plugins/ui.lua",
    "lua/plugins/workflow.lua",
    "lua/plugins/navigation.lua",
    "lua/features/pomodoro.lua",
    "lua/globals.lua",
  }

  local syntax_errors = 0
  for _, file in ipairs(config_files) do
    local full_path = vim.fn.stdpath("config") .. "/" .. file
    if utils.file_exists(full_path) then
      local fn, err = loadfile(full_path)
      if not fn then
        error(string.format("Syntax error in %s: %s", file, err))
        syntax_errors = syntax_errors + 1
      end
    else
      warn(string.format("Config file missing: %s", file))
    end
  end

  if syntax_errors == 0 then
    ok("All config files have valid Lua syntax")
  end

  -- Only count diagnostics originating from config buffers. Workspace
  -- warnings from the files a user happens to have open should not make the
  -- config health check look broken.
  local config_root = vim.fn.stdpath("config") .. "/"
  local diagnostics = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:sub(1, #config_root) == config_root then
      vim.list_extend(diagnostics, vim.diagnostic.get(buf))
    end
  end
  local error_count = 0
  local warning_count = 0

  for _, diag in ipairs(diagnostics) do
    if diag.severity == vim.diagnostic.severity.ERROR then
      error_count = error_count + 1
    elseif diag.severity == vim.diagnostic.severity.WARN then
      warning_count = warning_count + 1
    end
  end

  if error_count == 0 and warning_count == 0 then
    ok("No config diagnostic errors or warnings")
  elseif error_count == 0 then
    warn(string.format("%d config diagnostic warnings", warning_count))
  else
    error(string.format("%d config diagnostic errors, %d warnings", error_count, warning_count))
  end

  -- Check LSP client status
  local clients = vim.lsp.get_clients()
  if #clients > 0 then
    ok(string.format("%d LSP clients active", #clients))
    for _, client in ipairs(clients) do
      info(string.format("  - %s (%s)", client.name, client.root_dir or "no root"))
    end
  else
    info("No LSP clients active")
  end

  -- Check for plugin load errors
  lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local failed_plugins = {}
    for name, plugin in pairs(lazy.plugins()) do
      if plugin.error then
        table.insert(failed_plugins, name)
      end
    end
    if #failed_plugins == 0 then
      ok("All plugins loaded successfully")
    else
      error(string.format("%d plugins failed to load: %s", #failed_plugins, table.concat(failed_plugins, ", ")))
    end
  end

  -- Memory usage check
  local mem_kb = vim.uv.resident_set_memory() / 1024
  local mem_mb = mem_kb / 1024
  if mem_mb < memory_target_mb then
    ok(string.format("Memory usage: %.1f MB (target: <%dMB)", mem_mb, memory_target_mb))
  else
    warn(string.format("Memory usage: %.1f MB (target: <%dMB)", mem_mb, memory_target_mb))
  end

end

return M
