-- ============================================================================
-- Keymaps - Mad Engineer Efficiency Bindings
-- ============================================================================
---
--- This module defines all key mappings for efficient Neovim usage.
--- Leader key: Space | LocalLeader: \
---
--- Mappings are organized by category:
--- - Window navigation
--- - File operations
--- - Search and replace
--- - LSP and diagnostics
--- - Workflow shortcuts
---
--- All mappings use noremap and silent by default for reliability.
---
--- @module config.keymaps

local keymap = vim.keymap.set
local save = require("utils.save")

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Window left" })
keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Window down" })
keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Window up" })
keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Window right" })

-- Resize windows with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", { noremap = true, silent = true, desc = "Resize up" })
keymap("n", "<C-Down>", ":resize -2<CR>", { noremap = true, silent = true, desc = "Resize down" })
keymap("n", "<C-Left>", ":vertical resize -2<CR>", { noremap = true, silent = true, desc = "Resize left" })
keymap("n", "<C-Right>", ":vertical resize +2<CR>", { noremap = true, silent = true, desc = "Resize right" })

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })

-- Buffer operations (bd, bD, bw handled by snacks keys in core.lua)
keymap("n", "<leader>bn", ":bnext<CR>", { noremap = true, silent = true, desc = "[B]uffer [N]ext" })
keymap("n", "<leader>bp", ":bprevious<CR>", { noremap = true, silent = true, desc = "[B]uffer [P]revious" })
keymap("n", "<leader>bl", ":buffers<CR>", { noremap = true, silent = true, desc = "[B]uffer [L]ist" })

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
keymap("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })

-- Stay in indent mode
keymap("v", "<", "<gv", { noremap = true, silent = true, desc = "Indent left" })
keymap("v", ">", ">gv", { noremap = true, silent = true, desc = "Indent right" })

-- Better paste (don't yank replaced text)
keymap("v", "p", '"_dP', { noremap = true, silent = true, desc = "Paste without yank" })

-- Clear search highlight
keymap("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true, desc = "Clear search highlight" })

-- Better save and quit
keymap("n", "<C-s>", save.smart_save, { noremap = true, silent = true, desc = "Smart save" })
keymap("i", "<C-s>", function()
	save.smart_save()
	vim.cmd("startinsert")
end, { noremap = true, silent = true, desc = "Smart save" })
keymap("n", "<leader>qq", ":q<CR>", { noremap = true, silent = true, desc = "[Q]uit window" })
keymap("n", "<leader>Q", ":qa!<CR>", { noremap = true, silent = true, desc = "[Q]uit all (force)" })

-- Split windows
keymap("n", "<leader>wv", ":vsplit<CR>", { noremap = true, silent = true, desc = "[W]indow [V]ertical Split" })
keymap("n", "<leader>wh", ":split<CR>", { noremap = true, silent = true, desc = "[W]indow [H]orizontal Split" })
keymap("n", "<leader>wx", ":close<CR>", { noremap = true, silent = true, desc = "[W]indow Close" })

-- Tab management
keymap("n", "<leader>to", ":tabnew<CR>", { noremap = true, silent = true, desc = "[T]ab [O]pen" })
keymap("n", "<leader>tx", ":tabclose<CR>", { noremap = true, silent = true, desc = "[T]ab Close" })
keymap("n", "<leader><Tab>", ":tabn<CR>", { noremap = true, silent = true, desc = "Next Tab" })
keymap("n", "<leader><S-Tab>", ":tabp<CR>", { noremap = true, silent = true, desc = "Previous Tab" })

-- Theme switching (under <leader>u for UI)
-- Uses Lua functions to defer-require themes, avoiding fragile command load order
keymap("n", "<leader>us", function()
	require("utils.themes").switch_theme(vim.fn.input("Theme: "))
end, { noremap = true, silent = true, desc = "[U]I Theme [S]witch" })
keymap("n", "<leader>uN", function()
	require("utils.themes").next_theme()
end, { noremap = true, silent = true, desc = "[U]I Theme [N]ext" })
keymap("n", "<leader>uP", function()
	require("utils.themes").prev_theme()
end, { noremap = true, silent = true, desc = "[U]I Theme [P]revious" })
keymap("n", "<leader>uc", function()
	require("utils.themes").show_current()
end, { noremap = true, silent = true, desc = "[U]I Theme [C]urrent" })

-- Quick fix list
keymap("n", "<leader>co", ":copen<CR>", { noremap = true, silent = true, desc = "Quickfix [O]pen" })
keymap("n", "<leader>cc", ":cclose<CR>", { noremap = true, silent = true, desc = "Quickfix [C]lose" })
keymap("n", "]q", ":cnext<CR>", { noremap = true, silent = true, desc = "Next quickfix" })
keymap("n", "[q", ":cprev<CR>", { noremap = true, silent = true, desc = "Previous quickfix" })

-- Location list
keymap("n", "]l", ":lnext<CR>", { noremap = true, silent = true, desc = "Next location" })
keymap("n", "[l", ":lprev<CR>", { noremap = true, silent = true, desc = "Previous location" })

-- Diagnostic keymaps (LSP)
keymap("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { noremap = true, silent = true, desc = "Previous diagnostic" })
keymap("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { noremap = true, silent = true, desc = "Next diagnostic" })
keymap("n", "<leader>xf", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Diagnostic [F]loat" })
keymap("n", "<leader>xl", vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Diagnostic [L]ist" })
keymap("n", "<leader>xq", vim.diagnostic.setqflist, { noremap = true, silent = true, desc = "Diagnostic [Q]uickfix" })

-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true, desc = "Terminal window left" })
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true, desc = "Terminal window down" })
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true, desc = "Terminal window up" })
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", { noremap = true, silent = true, desc = "Terminal window right" })
