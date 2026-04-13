-- ============================================================================
-- Theme Switcher - Cycle between cyberdream, kanagawa, catppuccin, tokyonight
-- ============================================================================
---
--- This utility module manages theme switching and configuration.
--- Provides a unified interface for switching between different color schemes
--- with consistent lualine integration.
---
--- Available themes: cyberdream, kanagawa, catppuccin, tokyonight, oxocarbon
---
--- @module utils.themes
--- @field themes table List of available themes with their configurations

local M = {}

-- Available themes configuration
M.themes = {
  {
    name = "cyberdream",
    colorscheme = "cyberdream",
    plugin_name = "cyberdream.nvim",  -- Lazy.nvim plugin name
    description = "Futuristic Cyberpunk theme",
    lualine_theme = "custom_cyberpunk", -- Use custom theme from ui.lua
  },
  {
    name = "kanagawa",
    colorscheme = "kanagawa",
    plugin_name = "kanagawa.nvim", -- Lazy.nvim plugin name
    description = "Serene Japanese-inspired theme",
    lualine_theme = "auto",      -- Auto-detect from colorscheme
  },
  {
    name = "catppuccin",
    colorscheme = "catppuccin",
    plugin_name = "catppuccin", -- Has explicit name in plugin spec
    description = "Pastel theme (Mocha variant)",
    lualine_theme = "auto",
  },
  {
    name = "tokyonight",
    colorscheme = "tokyonight",
    plugin_name = "tokyonight.nvim", -- Lazy.nvim plugin name
    description = "Dark and vibrant theme (Night variant)",
    lualine_theme = "auto",
  },
  {
    name = "oxocarbon",
    colorscheme = "oxocarbon",
    plugin_name = "nyoom-engineering/oxocarbon.nvim", -- Lazy.nvim plugin name
    description = "IBM Carbon-inspired cyberpunk theme",
    lualine_theme = "auto",
  },
}

-- Default theme
M.default_theme = "cyberdream"

-- Store custom cyberdream highlights (set during plugin config)
M.cyberdream_highlights = nil

-- Store custom cyberpunk lualine theme (set during plugin config)
M.cyberpunk_lualine_theme = nil

-- Store lualine sections configuration (set during plugin config)
M.lualine_config = nil

-- Get current theme from global variable or default
M.get_current_theme = function()
  return vim.g.current_theme or M.default_theme
end

-- Set current theme
M.set_current_theme = function(theme_name)
  vim.g.current_theme = theme_name
end

-- Find theme index by name
M.find_theme_index = function(theme_name)
  for i, theme in ipairs(M.themes) do
    if theme.name == theme_name then
      return i
    end
  end
  return nil
end

-- Register custom highlights for cyberdream (called from ui.lua config)
M.register_cyberdream_highlights = function(highlights)
  M.cyberdream_highlights = highlights
end

-- Register custom cyberpunk lualine theme (called from ui.lua config)
M.register_cyberpunk_lualine = function(theme_config)
  M.cyberpunk_lualine_theme = theme_config
end

-- Register lualine configuration (called from ui.lua config)
M.register_lualine_config = function(config)
  M.lualine_config = config
end

-- Apply custom cyberdream highlights
M.apply_cyberdream_highlights = function()
  if M.cyberdream_highlights then
    for group, colors in pairs(M.cyberdream_highlights) do
      vim.api.nvim_set_hl(0, group, colors)
    end
  end
end

-- Apply lualine theme based on current colorscheme
M.apply_lualine_theme = function(theme_name)
  local ok, lualine = pcall(require, "lualine")
  if not ok or not M.lualine_config then
    return
  end

  -- Always reconfigure lualine with the appropriate theme
  local config = vim.deepcopy(M.lualine_config)

  if theme_name == "cyberdream" and M.cyberpunk_lualine_theme then
    -- Use custom cyberpunk theme for cyberdream
    config.options.theme = M.cyberpunk_lualine_theme
  else
    -- Use auto-detect for other themes
    config.options.theme = "auto"
  end

  lualine.setup(config)
end

-- Stored by ui.lua's bufferline config function (preserves function refs)
M.bufferline_config = nil

-- Refresh bufferline to pick up new colorscheme
M.refresh_bufferline = function()
  local ok, bufferline = pcall(require, "bufferline")
  if ok and M.bufferline_config then
    pcall(function()
      bufferline.setup(M.bufferline_config)
    end)
  end
end

-- Apply theme
M.apply_theme = function(theme_name)
  theme_name = theme_name or M.get_current_theme()

  -- Find the theme in our list
  local theme = nil
  for _, t in ipairs(M.themes) do
    if t.name == theme_name then
      theme = t
      break
    end
  end

  if not theme then
    vim.notify("Theme '" .. theme_name .. "' not found. Using default.", vim.log.levels.WARN)
    theme_name = M.default_theme
    theme = M.themes[1]
  end

  -- Try to load the plugin if it's lazy-loaded
  pcall(function()
    require("lazy").load({ plugins = { theme.plugin_name } })
  end)

  -- Apply the colorscheme
  local success, err = pcall(function()
    vim.cmd.colorscheme(theme.colorscheme)
  end)

  if success then
    M.set_current_theme(theme_name)

    -- Apply theme-specific customizations with a small delay
    -- to ensure colorscheme is fully applied
    vim.defer_fn(function()
      -- Apply custom highlights for cyberdream
      if theme_name == "cyberdream" then
        M.apply_cyberdream_highlights()
      end

      -- Update lualine theme
      M.apply_lualine_theme(theme_name)

      -- Refresh bufferline
      M.refresh_bufferline()
    end, 50)

    vim.notify("Theme: " .. theme.description, vim.log.levels.INFO)
  else
    vim.notify("Failed to load theme '" .. theme_name .. "': " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Switch to next theme
M.next_theme = function()
  local current = M.get_current_theme()
  local current_idx = M.find_theme_index(current) or 1
  local next_idx = (current_idx % #M.themes) + 1
  M.apply_theme(M.themes[next_idx].name)
end

-- Switch to previous theme
M.prev_theme = function()
  local current = M.get_current_theme()
  local current_idx = M.find_theme_index(current) or 1
  local prev_idx = current_idx == 1 and #M.themes or current_idx - 1
  M.apply_theme(M.themes[prev_idx].name)
end

-- Show current theme
M.show_current = function()
  local current = M.get_current_theme()
  local theme = nil
  for _, t in ipairs(M.themes) do
    if t.name == current then
      theme = t
      break
    end
  end

  if theme then
    vim.notify("Current theme: " .. theme.description .. " (" .. theme.name .. ")", vim.log.levels.INFO)
  else
    vim.notify("Current theme: " .. current, vim.log.levels.INFO)
  end
end

-- Interactive theme switcher with completion
M.switch_theme = function(theme_name)
  if theme_name and theme_name ~= "" then
    M.apply_theme(theme_name)
  else
    -- Show available themes
    local themes_list = {}
    for _, theme in ipairs(M.themes) do
      table.insert(themes_list, theme.name .. " - " .. theme.description)
    end
    vim.notify("Available themes:\n" .. table.concat(themes_list, "\n"), vim.log.levels.INFO)
  end
end

-- Setup user commands
M.setup_commands = function()
  -- Command to switch to specific theme with completion
  vim.api.nvim_create_user_command("ThemeSwitch", function(opts)
    M.switch_theme(opts.args)
  end, {
    nargs = "?",
    complete = function()
      local theme_names = {}
      for _, theme in ipairs(M.themes) do
        table.insert(theme_names, theme.name)
      end
      return theme_names
    end,
    desc = "Switch to a specific theme",
  })

  -- Command to cycle to next theme
  vim.api.nvim_create_user_command("ThemeNext", function()
    M.next_theme()
  end, {
    desc = "Switch to next theme",
  })

  -- Command to cycle to previous theme
  vim.api.nvim_create_user_command("ThemePrev", function()
    M.prev_theme()
  end, {
    desc = "Switch to previous theme",
  })

  -- Command to show current theme
  vim.api.nvim_create_user_command("ThemeCurrent", function()
    M.show_current()
  end, {
    desc = "Show current theme",
  })
end

-- Initialize theme switcher
M.setup = function()
  M.setup_commands()
end

-- Auto-setup on require: registers theme commands immediately so they're
-- available as soon as the module is loaded (before any plugin setup runs).
M.setup()

return M
