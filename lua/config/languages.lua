-- ============================================================================
-- Language-Specific Settings
-- ============================================================================
---
--- This module configures language-specific settings and autocommands.
--- Includes indentation, formatting, and workflow settings for different languages.
---
--- Currently supports:
--- - Python
--- - Go
--- - Rust
--- - JavaScript/TypeScript
--- - Lua
---
--- @module config.languages

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Python
autocmd("FileType", {
  group = augroup("PythonSettings", { clear = true }),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 88 -- Black formatter default
  end,
})

-- TypeScript/JavaScript
autocmd("FileType", {
  group = augroup("TypeScriptSettings", { clear = true }),
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Go
autocmd("FileType", {
  group = augroup("GoSettings", { clear = true }),
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false -- Go uses tabs
  end,
})

-- Rust
autocmd("FileType", {
  group = augroup("RustSettings", { clear = true }),
  pattern = "rust",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- SQL
autocmd("FileType", {
  group = augroup("SQLSettings", { clear = true }),
  pattern = "sql",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- GDScript (Godot)
autocmd("FileType", {
  group = augroup("GDScriptSettings", { clear = true }),
  pattern = "gdscript",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false -- GDScript uses tabs
  end,
})

-- Lua
autocmd("FileType", {
  group = augroup("LuaSettings", { clear = true }),
  pattern = "lua",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Markdown
autocmd("FileType", {
  group = augroup("MarkdownSettings", { clear = true }),
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- JSON/YAML
autocmd("FileType", {
  group = augroup("ConfigSettings", { clear = true }),
  pattern = { "json", "yaml", "yml", "toml" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})

-- Docker
autocmd("FileType", {
  group = augroup("DockerSettings", { clear = true }),
  pattern = "dockerfile",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
  end,
})

-- Shell scripts (Bash, Zsh, Fish)
autocmd("FileType", {
  group = augroup("ShellSettings", { clear = true }),
  pattern = { "sh", "bash", "zsh", "fish" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end,
})
