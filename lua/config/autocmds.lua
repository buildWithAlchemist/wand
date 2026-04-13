--- ============================================================================
--- Autocommands - Filetype detection, performance optimizations
--- ============================================================================
---
--- This module defines all autocommands for automatic behavior based on events.
--- Includes filetype-specific settings, performance optimizations for large files,
--- and workflow enhancements.
---
--- Autocommands are grouped by purpose for maintainability.
---
---@module config.autocmds

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Handle directory opening (VSCode-style explorer)
autocmd("VimEnter", {
  group = augroup("DirectoryExplorer", { clear = true }),
  callback = function()
    local args = vim.fn.argv()
    if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
      vim.schedule(function()
        require("oil").open(args[1])
      end)
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("HighlightYank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
autocmd("BufWritePre", {
  group = augroup("TrimWhitespace", { clear = true }),
  pattern = "*",
  callback = function()
    if not vim.bo.modifiable or vim.bo.buftype ~= "" or vim.b.skip_save_hooks then
      return
    end
    -- Skip for big files to prevent performance issues
    local max_filesize = 1024 * 1024 -- 1MB
    local filepath = vim.fn.expand("%:p")
    local filesize = filepath ~= "" and vim.fn.getfsize(filepath) or 0
    if filesize > max_filesize or vim.bo.filetype == "bigfile" then
      return
    end
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- Auto-create directories when saving
autocmd("BufWritePre", {
  group = augroup("AutoMkdir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Close certain filetypes with 'q'
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = {
    "qf",
    "help",
    "man",
    "notify",
    "lspinfo",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "PlenaryTestPopup",
    "checkhealth",
    "dap-float",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "oil",
    "trouble",
    "lazy",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    -- Disposable filetypes: safe to force-delete after closing
    local disposable = {
      qf = true,
      help = true,
      man = true,
      notify = true,
      lspinfo = true,
      spectre_panel = true,
      startuptime = true,
      tsplayground = true,
      PlenaryTestPopup = true,
      checkhealth = true,
      ["dap-float"] = true,
      dbout = true,
      ["gitsigns-blame"] = true,
    }
    local ft = vim.bo[event.buf].filetype
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then return end
      vim.keymap.set("n", "q", function()
        if #vim.api.nvim_list_wins() > 1 then
          vim.cmd("close")
        elseif disposable[ft] then
          vim.cmd("enew")
        end
        if disposable[ft] then
          pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
        end
      end, { buffer = event.buf, silent = true, desc = "Close window" })
    end)
  end,
})

-- Close floating windows with 'q' (catch-all for plugin floats)
autocmd("BufWinEnter", {
  group = augroup("CloseFloatWithQ", { clear = true }),
  callback = function(event)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(win).relative == "" then return end
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) then return end
      -- Don't override if a buffer-local q mapping already exists
      local maps = vim.api.nvim_buf_get_keymap(event.buf, "n")
      for _, map in ipairs(maps) do
        if map.lhs == "q" then return end
      end
      vim.keymap.set("n", "q", "<cmd>close<cr>",
        { buffer = event.buf, noremap = true, silent = true, desc = "Close float" })
    end)
  end,
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = augroup("RestoreCursor", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Check if we need to reload the file when it changed
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("Checktime", { clear = true }),
  command = "checktime",
})

-- Set wrap for certain file types
autocmd("FileType", {
  group = augroup("WrapSpell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Don't auto-comment new lines
autocmd("BufEnter", {
  group = augroup("DisableAutoComment", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Handle large pastes/inserts to prevent hangs
local large_insert_group = augroup("LargeInsertHandling", { clear = true })

autocmd("InsertEnter", {
  group = large_insert_group,
  callback = function()
    if vim.fn.line('$') > 10000 then
      vim.cmd("syntax off")
      pcall(function() vim.cmd("TSBufDisable highlight") end)
    end
  end,
})

autocmd("InsertLeave", {
  group = large_insert_group,
  callback = function()
    if vim.fn.line('$') > 10000 then
      vim.cmd("syntax on")
      pcall(function() vim.cmd("TSBufEnable highlight") end)
    end
  end,
})

-- Terminal settings
autocmd("TermOpen", {
  group = augroup("TerminalSettings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end,
})

-- Scaffold new Jupyter notebook files with basic structure
autocmd("BufNewFile", {
  group = augroup("ScaffoldJupyterNotebook", { clear = true }),
  pattern = "*.ipynb",
  callback = function()
    -- Insert minimal valid Jupyter notebook JSON structure
    local lines = {
      "{",
      ' "cells": [],',
      ' "metadata": {',
      '  "kernelspec": {',
      '   "display_name": "Python 3",',
      '   "language": "python",',
      '   "name": "python3"',
      "  },",
      '  "language_info": {',
      '   "name": "python",',
      '   "version": "3.x"',
      "  }",
      " },",
      ' "nbformat": 4,',
      ' "nbformat_minor": 5',
      "}",
    }
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    -- Mark buffer as modified so it prompts to save
    vim.bo.modified = true
  end,
})

-- Big file save hooks — snacks.bigfile handles disabling heavy features (LSP,
-- treesitter, etc.), but we still need to flag large files for our save system.
autocmd("BufReadPost", {
  group = augroup("BigFileSaveHooks", { clear = true }),
  callback = function()
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then return end
    local filesize = vim.fn.getfsize(filepath)
    -- Skip format-on-save and whitespace trim for files >500KB
    if filesize > 512 * 1024 then
      vim.b.skip_save_hooks = true
    end
  end,
})
