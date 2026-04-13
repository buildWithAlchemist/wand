-- ============================================================================
-- UI Plugins - Themes, statusline, notifications, dashboard
-- ============================================================================
---
--- This module configures all UI-related plugins for the Neovim interface.
--- It includes:
--- - Color schemes and themes (cyberdream, tokyonight, oxocarbon)
--- - Statusline configuration (lualine with cyberpunk theme)
--- - Dashboard, notifications, terminals, etc. (snacks.nvim — see core.lua)
--- - UI enhancements (noice, colorizer)
---
--- The configuration emphasizes the cyberpunk aesthetic with neon colors,
--- smooth animations, and a cohesive visual experience.
---
---@module plugins.ui

return {
  -- Cyberdream: Futuristic Cyberpunk colorscheme
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cyberdream").setup({
        transparent = false,
        italic_comments = true,
        hide_fillchars = false,
        borderless_telescope = false,
        terminal_colors = true,
      })

      -- Neon cyberpunk highlights (WCAG AA compliant)
      local highlights = {
        -- Core editor
        Normal = { fg = "#d6d6d9", bg = "#0a0a0f" },
        NormalFloat = { fg = "#d6d6d9", bg = "#111119" },
        FloatBorder = { fg = "#4da3ff", bg = "#111119" },

        Comment = { fg = "#8a8f9b", italic = true },
        Keyword = { fg = "#ff52ff" },
        Function = { fg = "#00e5f0" },
        String = { fg = "#78e85b" },
        Number = { fg = "#eacc5a" },
        Type = { fg = "#eacc5a" },
        Operator = { fg = "#4da3ff" },
        Variable = { fg = "#4da3ff" },
        Constant = { fg = "#ff874d" },
        Identifier = { fg = "#b884ff" },

        -- Control flow and statements
        Conditional = { fg = "#ff52ff" },
        Repeat = { fg = "#ff52ff" },
        Label = { fg = "#4da3ff" },
        Exception = { fg = "#ff52ff" },

        -- Preprocessor
        PreProc = { fg = "#b884ff" },
        Include = { fg = "#b884ff" },
        Define = { fg = "#b884ff" },
        Macro = { fg = "#b884ff" },

        -- Types & structures
        StorageClass = { fg = "#eacc5a" },
        Structure = { fg = "#eacc5a" },
        Typedef = { fg = "#eacc5a" },

        -- Special
        Special = { fg = "#b884ff" },
        SpecialChar = { fg = "#b884ff" },
        Delimiter = { fg = "#858994" },
        SpecialComment = { fg = "#8a8f9b", italic = true, bold = true },

        -- Diagnostics (neon, WCAG AA compliant)
        DiagnosticError = { fg = "#ff4f6e", bold = true },
        DiagnosticWarn = { fg = "#ffb347", bold = true },
        DiagnosticInfo = { fg = "#4da3ff", bold = true },
        DiagnosticHint = { fg = "#78e85b", bold = true },

        -- Git signs
        GitSignsAdd = { fg = "#78e85b", bold = true },
        GitSignsChange = { fg = "#eacc5a", bold = true },
        GitSignsDelete = { fg = "#ff4f6e", bold = true },

        -- LSP references
        LspReferenceText = { bg = "#1a1a24" },
        LspReferenceRead = { bg = "#1a1a24" },
        LspReferenceWrite = { bg = "#1a1a24" },

        -- Treesitter context
        TreesitterContext = { bg = "#12121a" },
        TreesitterContextLineNumber = { fg = "#8a8f9b", bg = "#12121a" },

        -- Search / selection
        Search = { fg = "#0a0a0f", bg = "#eacc5a", bold = true },
        IncSearch = { fg = "#0a0a0f", bg = "#ff52ff", bold = true },
        Visual = { bg = "#2e2040" },

        -- UI
        LineNr = { fg = "#7e828c" },
        CursorLineNr = { fg = "#00e5f0", bold = true },
        CursorLine = { bg = "#12121a" },
        SignColumn = { bg = "#0a0a0f" },
        FoldColumn = { fg = "#7e828c", bg = "#0a0a0f" },

        WinSeparator = { fg = "#4a4a55" },
        VertSplit = { fg = "#4a4a55" },

        -- Completion menu
        Pmenu = { fg = "#d6d6d9", bg = "#111119" },
        PmenuSel = { fg = "#00e5f0", bg = "#1b1b22", bold = true },
        PmenuSbar = { bg = "#1b1b22" },
        PmenuThumb = { bg = "#ff52ff" },

        -- Telescope borders
        TelescopeBorder = { fg = "#ff52ff" },
        TelescopePromptBorder = { fg = "#ff52ff" },
        TelescopeResultsBorder = { fg = "#4da3ff" },
        TelescopePreviewBorder = { fg = "#4da3ff" },
        TelescopeTitle = { fg = "#00e5f0", bold = true },

        -- WhichKey
        WhichKey = { fg = "#00e5f0" },
        WhichKeyGroup = { fg = "#ff52ff" },
        WhichKeyDesc = { fg = "#d6d6d9" },
        WhichKeySeparator = { fg = "#7e828c" },

        -- Dashboard
        DashboardHeader = { fg = "#00e5f0", bold = true },
        DashboardCenter = { fg = "#ff52ff" },
        DashboardFooter = { fg = "#78e85b", italic = true },
        DashboardShortcut = { fg = "#eacc5a" },

        -- Enhanced Treesitter syntax highlighting
        ["@variable"] = { fg = "#4da3ff" },
        ["@variable.builtin"] = { fg = "#ff874d", italic = true },
        ["@variable.parameter"] = { fg = "#ff874d", italic = true },
        ["@variable.member"] = { fg = "#b884ff" },

        ["@function"] = { fg = "#00e5f0" },
        ["@function.call"] = { fg = "#00e5f0" },
        ["@function.builtin"] = { fg = "#00e5f0", italic = true },
        ["@method"] = { fg = "#00e5f0", italic = true },
        ["@method.call"] = { fg = "#00e5f0", italic = true },

        ["@keyword"] = { fg = "#ff52ff", italic = true },
        ["@keyword.function"] = { fg = "#eacc5a" },
        ["@keyword.return"] = { fg = "#ff52ff", italic = true },
        ["@keyword.operator"] = { fg = "#4da3ff" },

        ["@type"] = { fg = "#eacc5a" },
        ["@type.builtin"] = { fg = "#eacc5a", italic = true },
        ["@class"] = { fg = "#eacc5a" },
        ["@struct"] = { fg = "#eacc5a" },
        ["@interface"] = { fg = "#eacc5a" },

        ["@constant"] = { fg = "#ff874d" },
        ["@constant.builtin"] = { fg = "#ff874d", italic = true },

        ["@string"] = { fg = "#78e85b" },
        ["@string.escape"] = { fg = "#b884ff", bold = true },
        ["@string.special"] = { fg = "#b884ff" },

        ["@number"] = { fg = "#eacc5a" },
        ["@boolean"] = { fg = "#ff874d" },

        ["@operator"] = { fg = "#4da3ff" },
        ["@punctuation"] = { fg = "#858994" },
        ["@punctuation.bracket"] = { fg = "#858994" },
        ["@punctuation.delimiter"] = { fg = "#858994" },

        ["@comment"] = { fg = "#8a8f9b", italic = true },
        ["@comment.todo"] = { fg = "#eacc5a", bold = true },
        ["@comment.note"] = { fg = "#4da3ff", bold = true },
        ["@comment.warning"] = { fg = "#ff4f6e", bold = true },
      }

      -- Apply colorscheme directly
      vim.cmd("colorscheme cyberdream")

      -- Apply custom highlights
      for group, colors in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, colors)
      end

      -- Register custom highlights with theme switcher for when we switch back to cyberdream
      local theme_switcher = require("utils.themes")
      theme_switcher.register_cyberdream_highlights(highlights)
    end,
  },

  -- Kanagawa: Serene Japanese-inspired colorscheme
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = false,
        dimInactive = false,
        terminalColors = true,
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
      })
    end,
  },

  -- Catppuccin: Pastel colorscheme with multiple variants
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          cmp = false,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          telescope = {
            enabled = true,
          },
          which_key = true,
          noice = true,
          mason = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
            inlay_hints = {
              background = true,
            },
          },
        },
      })
    end,
  },

  -- TokyoNight: Dark and vibrant colorscheme
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help" },
        day_brightness = 0.3,
        hide_inactive_statusline = false,
        dim_inactive = false,
        lualine_bold = true,
      })
    end,
  },

  -- Oxocarbon: IBM Carbon-inspired cyberpunk colorscheme
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      vim.opt.background = "dark"
      vim.cmd.colorscheme("oxocarbon")
    end,
  },

  -- Lualine: Dynamic Statusline (adapts to active theme)
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Neon cyberpunk lualine theme (only for cyberdream)
      local cyberpunk_theme = vim.g.lualine_cyberpunk_theme or {
        normal = {
          a = { fg = "#0a0a0f", bg = "#00e5f0", gui = "bold" },
          b = { fg = "#00e5f0", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#00e5f0", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#00e5f0", gui = "bold" },
          y = { fg = "#00e5f0", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#00e5f0", gui = "bold" },
        },
        insert = {
          a = { fg = "#0a0a0f", bg = "#78e85b", gui = "bold" },
          b = { fg = "#78e85b", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#78e85b", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#78e85b", gui = "bold" },
          y = { fg = "#78e85b", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#78e85b", gui = "bold" },
        },
        visual = {
          a = { fg = "#0a0a0f", bg = "#ff52ff", gui = "bold" },
          b = { fg = "#ff52ff", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#ff52ff", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#ff52ff", gui = "bold" },
          y = { fg = "#ff52ff", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#ff52ff", gui = "bold" },
        },
        replace = {
          a = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          b = { fg = "#ff4f6e", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          y = { fg = "#ff4f6e", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
        },
        command = {
          a = { fg = "#0a0a0f", bg = "#b884ff", gui = "bold" },
          b = { fg = "#b884ff", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#b884ff", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#b884ff", gui = "bold" },
          y = { fg = "#b884ff", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#b884ff", gui = "bold" },
        },
        terminal = {
          a = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          b = { fg = "#ff4f6e", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          x = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
          y = { fg = "#ff4f6e", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#0a0a0f", bg = "#ff4f6e", gui = "bold" },
        },
        inactive = {
          a = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
          b = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
          c = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
          x = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
          y = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
          z = { fg = "#8a8e98", bg = "#1b1b22", gui = "bold" },
        },
      }

      -- Store cyberpunk theme globally
      vim.g.lualine_cyberpunk_theme = cyberpunk_theme

      -- Language icon mapping
      local lang_icons = {
        lua = "",
        python = "",
        javascript = "",
        typescript = "",
        react = "",
        html = "",
        css = "",
        scss = "",
        json = "",
        yaml = "",
        toml = "",
        go = "",
        rust = "",
        c = "",
        cpp = "",
        java = "",
        php = "",
        ruby = "",
        perl = "",
        sh = "",
        zsh = "",
        fish = "",
        vim = "",
        tex = "",
        markdown = "",
        sql = "",
        dockerfile = "",
        gitignore = "",
        conf = "",
        make = "",
      }

      -- Build lualine configuration
      local config = {
        options = {
          theme = "auto", -- Will be updated by theme switcher for cyberdream
          component_separators = { left = "|", right = "|" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            { "mode", icon = nil, fmt = function(str) return str:sub(1, 1) end, padding = { left = 1, right = 1 }, gui = "bold" },
          },
          lualine_b = {
            {
              "branch",
              icon = "",
              fmt = function(str)
                return str ~= "" and
                    str or ""
              end,
              padding = { left = 1, right = 1 },
              gui = "bold"
            },
            { "diff", fmt = function(str) return str ~= "" and str or "" end, padding = { left = 1, right = 1 }, gui = "bold" },
          },
          lualine_c = {
            {
              function()
                local ft = vim.bo.filetype
                local icon = lang_icons[ft] or "󰈔"
                local fname = vim.fn.expand("%:t")
                return fname ~= "" and icon .. " " .. fname or ""
              end,
              gui = "bold"
            },
            { "searchcount",    gui = "bold" },
            { "selectioncount", gui = "bold" },
            { "diagnostics",    colored = false, gui = "bold" },
          },
          lualine_x = { { "encoding", gui = "bold" }, { "fileformat", gui = "bold" } },
          lualine_y = {
            {
              function() return require("pomodoro").lualine() end,
              gui = "bold",
              cond = function()
                return require("pomodoro").is_active()
              end,
            },
            { "progress", padding = { left = 1, right = 1 }, gui = "bold" },
            { "location", padding = { left = 1, right = 1 }, gui = "bold" },
          },
          lualine_z = { { function() return os.date("%a %d %H:%M") end, gui = "bold" } },
        },
        extensions = { "oil", "aerial", "trouble", "lazy", "mason" },
      }

      -- Add navic context
      table.insert(config.sections.lualine_x, 2, {
        function()
          local navic_ok, navic = pcall(require, "nvim-navic")
          if navic_ok and navic.is_available() then
            local location = navic.get_location()
            return location ~= "" and " " .. location or ""
          end
          return ""
        end,
        cond = function()
          local navic_ok, navic = pcall(require, "nvim-navic")
          return navic_ok and navic.is_available() and navic.get_location() ~= ""
        end,
        gui = "bold"
      })

      -- Add AI sidekick status
      table.insert(config.sections.lualine_x, 3, {
        function()
          local status = require("sidekick.status").cli()
          return #status > 0 and "🤖 " .. (#status > 1 and #status or "") or ""
        end,
        cond = function()
          return #require("sidekick.status").cli() > 0
        end,
        padding = { left = 0, right = 1 },
        gui = "bold"
      })

      -- Register with theme switcher
      local theme_switcher = require("utils.themes")
      theme_switcher.register_cyberpunk_lualine(cyberpunk_theme)
      theme_switcher.register_lualine_config(config)

      -- Apply cyberpunk theme if currently on cyberdream
      local current_theme = theme_switcher.get_current_theme()
      if current_theme == "cyberdream" then
        config.options.theme = cyberpunk_theme
      end

      require("lualine").setup(config)
    end,
  },

  -- Bufferline: Tab/buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    version = "*",
    keys = {
      { "<leader>wt", "<Cmd>BufferLineCycleNext<CR>", desc = "[W]indow [T]ab Next" },
      { "<leader>wT", "<Cmd>BufferLineCyclePrev<CR>", desc = "[W]indow [T]ab Prev" },
      { "<leader>wp", "<Cmd>BufferLinePick<CR>",      desc = "[W]indow [T]ab Pick" },
      { "<leader>wc", "<Cmd>BufferLinePickClose<CR>", desc = "[W]indow [T]ab Close" },
      { "<leader>w>", "<Cmd>BufferLineMoveNext<CR>",  desc = "[W]indow [T]ab Move Next" },
      { "<leader>w<", "<Cmd>BufferLineMovePrev<CR>",  desc = "[W]indow [T]ab Move Prev" },
    },
    config = function()
      local bufferline_config = {
        options = {
          mode = "buffers",
          numbers = "none",
          diagnostics = "nvim_lsp",
          color_icons = true,
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          show_tab_indicators = true,
          show_duplicate_prefix = true,
          persist_buffer_sort = true,
          move_wraps_at_ends = true,
          separator_style = { "", "" },
          enforce_regular_tabs = false,
          always_show_bufferline = true,
          auto_toggle_bufferline = true,
          sort_by = "insert_after_current",
          close_command = function(n) require("snacks").bufdelete(n) end,
          right_mouse_command = function(n) require("snacks").bufdelete(n) end,
          mappings = false,
        },
      }

      -- Store config on themes module (not vim.g, which loses function refs via msgpack)
      local themes_ok, themes = pcall(require, "utils.themes")
      if themes_ok then
        themes.bufferline_config = bufferline_config
      end

      require("bufferline").setup(bufferline_config)
    end,
  },

  -- Noice: Better UI for messages, cmdline, and popupmenu
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      -- Clear stale messages if lazy.nvim UI is still open (fresh install)
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
        },
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },
        popupmenu = {
          enabled = true,
          backend = "nui",
          border = {
            style = "single",
          },
        },
        notify = {
          enabled = false, -- snacks.notifier handles vim.notify
          view = "notify",
        },
        routes = {
          -- Suppress treesitter install nvim_echo messages
          { filter = { event = "msg_show", find = "^%[nvim%-treesitter" }, opts = { skip = true } },
          -- Suppress mason install vim.notify messages
          {
            filter = {
              event = "notify",
              cond = function(msg)
                return msg.opts and (msg.opts.title or ""):find("mason") ~= nil
              end,
            },
            opts = { skip = true },
          },
        },
      })
    end,
  },


  -- Colorizer: Show colors inline
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>uC", "<cmd>ColorizerToggle<cr>", desc = "[U]I [C]olorizer Toggle" },
    },
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = {
          RGB = true,
          RRGGBB = true,
          names = true,
          css = true,
          css_fn = true,
          tailwind = false,
          mode = "virtualtext",
          virtualtext = "  ",
        },
      })
    end,
  },
}
