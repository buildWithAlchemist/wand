-- ============================================================================
-- Vim Options - Optimized for Performance & Mad Engineer Workflow
-- ============================================================================
---
--- This module configures all Vim options for optimal performance and workflow.
--- Options are grouped by category for easy maintenance and understanding.
---
--- Performance optimizations, UI enhancements, editing preferences, and
--- workflow-specific settings are all configured here.
---
--- @module config.options

local opt = vim.opt

-- Performance
opt.updatetime = 250   -- Faster completion and gitsigns
opt.timeoutlen = 300   -- Faster which-key popup
vim.o.timeout = true   -- Required for timeoutlen to apply
opt.lazyredraw = false -- Don't use lazyredraw (causes issues with noice)

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- Always show sign column to prevent text shift
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false          -- Don't show mode (lualine shows it)
opt.cmdheight = 0             -- Hide command line (noice will handle)
opt.pumheight = 10            -- Max items in completion menu
opt.scrolloff = 8             -- Keep 8 lines above/below cursor
opt.fillchars = { eob = " " } -- Disable ~ on empty lines
opt.sidescrolloff = 8
opt.wrap = false              -- No line wrapping by default

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true -- Case sensitive if search contains uppercase
opt.hlsearch = true
opt.incsearch = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Backups
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true -- Persistent undo
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Clipboard
opt.clipboard = "unnamedplus" -- Use system clipboard

-- Mouse
opt.mouse = "a" -- Enable mouse in all modes

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Other
opt.hidden = true                   -- Allow switching buffers without saving
opt.fileencoding = "utf-8"
opt.conceallevel = 0                -- Don't hide characters (markdown, etc.)
opt.iskeyword:append("-")           -- Treat dash-separated words as one word
opt.whichwrap:append("<,>,[,],h,l") -- Allow these keys to move to prev/next line
opt.shortmess:append("c")           -- Don't show completion messages

-- Folding (managed by nvim-ufo)
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true

-- Performance optimizations
opt.synmaxcol = 1000 -- Allow syntax highlighting on longer lines for big files
opt.laststatus = 3   -- Global statusline

-- Python provider (enable for molten)
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
