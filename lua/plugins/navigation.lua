-- ============================================================================
-- Navigation Plugins - Fuzzy finding, file management, code outline
-- ============================================================================
---
--- This module configures plugins for efficient navigation within Neovim.
--- Includes fuzzy finding, file management, code outlining, and movement aids.
---
--- Features:
--- - Telescope for fuzzy finding
--- - Oil for file management
--- - Aerial for code outline
--- - Flash/Leap for character jumping
--- - Harpoon for file bookmarks
---
---@module plugins.navigation

return {
  -- Telescope: Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "[F]ind [F]iles" },
      {
        "<leader>fF",
        function()
          local root = require("project_nvim.project").get_project_root()
          require("telescope.builtin").find_files({ cwd = root, no_ignore = true, hidden = true })
        end,
        desc = "[F]ind [F]iles (project root)",
      },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "[F]ind by [G]rep" },
      {
        "<leader>fG",
        function()
          local root = require("project_nvim.project").get_project_root()
          require("telescope.builtin").live_grep({ cwd = root, additional_args = { "--no-ignore", "--hidden" } })
        end,
        desc = "[F]ind by [G]rep (project root)",
      },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",              desc = "[F]ind [B]uffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",            desc = "[F]ind [H]elp" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",             desc = "[F]ind [R]ecent Files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",             desc = "[F]ind [C]ommands" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",              desc = "[F]ind [K]eymaps" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "[F]ind [S]ymbols" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>",          desc = "[F]ind [W]ord" },
      {
        "<leader>fW",
        function()
          local root = require("project_nvim.project").get_project_root()
          require("telescope.builtin").grep_string({ cwd = root })
        end,
        desc = "[F]ind [W]ord (project root)",
      },
      { "<leader>li", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "[L]SP [I]ncoming Calls" },
      { "<leader>lo", "<cmd>Telescope lsp_outgoing_calls<cr>", desc = "[L]SP [O]utgoing Calls" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = "> ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          winblend = 0,
          borderchars = {
            prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          },
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
            "target/",
            "%.lock",
          },
          mappings = {
            i = {
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["<esc>"] = actions.close,
              ["<CR>"] = actions.select_default,
              ["<C-x>"] = actions.select_horizontal,
              ["<C-v>"] = actions.select_vertical,
              ["<C-t>"] = actions.select_tab,
              ["j"] = actions.move_selection_next,
              ["k"] = actions.move_selection_previous,
              ["<Down>"] = actions.move_selection_next,
              ["<Up>"] = actions.move_selection_previous,
              ["q"] = actions.close,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true, -- Shows dotfiles, but respects file_ignore_patterns above
            -- Use <leader>fF to search ALL files including ignored ones
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")

      -- Notification history handled by Snacks.notifier.show_history()
    end,
  },

  -- Oil: File manager as a buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-",         "<cmd>lua require('oil').open_float()<cr>", desc = "Open parent directory (float)" },
      { "<leader>-", "<cmd>lua require('oil').open()<cr>",       desc = "Open parent directory" },
      { "<leader>e", "<cmd>lua require('oil').open_float()<cr>", desc = "[E]xplorer (float)" },
    },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = {
          "icon",
        },
        buf_options = {
          buflisted = false,
          bufhidden = "hide",
        },
        win_options = {
          wrap = false,
          signcolumn = "no",
          cursorcolumn = false,
          foldcolumn = "0",
          spell = false,
          list = false,
          conceallevel = 3,
          concealcursor = "nvic",
        },
        delete_to_trash = false,
        skip_confirm_for_simple_edits = false,
        prompt_save_on_select_new_entry = true,
        cleanup_delay_ms = 2000,
        keymaps = {
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.select",
          ["<C-v>"] = "actions.select_vsplit",
          ["<C-x>"] = "actions.select_split",
          ["<C-t>"] = "actions.select_tab",
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = "actions.close",
          ["<C-r>"] = "actions.refresh",
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = "actions.tcd",
          ["gs"] = "actions.change_sort",
          ["gx"] = "actions.open_external",
          ["g."] = "actions.toggle_hidden",
          ["g\\"] = "actions.toggle_trash",
          ["<C-s>"] = false, -- disable oil's default split; global <C-s> save takes over
        },
        use_default_keymaps = true,
        view_options = {
          show_hidden = false, -- Toggle with g. inside Oil buffer

          is_hidden_file = function(name, _)
            return vim.startswith(name, ".")
          end,
          is_always_hidden = function(_, _)
            return false
          end,
        },
        float = {
          padding = 2,
          max_width = 120,
          max_height = 30,
          border = "single",
          win_options = {
            winblend = 0,
          },
          override = function(conf)
            -- Center the float window
            return conf
          end,
        },
      })
    end,
  },

  -- Aerial: Code outline sidebar
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialInfo" },
    keys = {
      { "<leader>oo", "<cmd>AerialToggle!<CR>", desc = "[O]utline Toggle" },
      { "{",         "<cmd>AerialPrev<CR>",    desc = "Previous Function" },
      { "}",         "<cmd>AerialNext<CR>",    desc = "Next Function" },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("aerial").setup({
        backends = { "treesitter", "lsp", "markdown", "man" },
        layout = {
          max_width = { 40, 0.2 },
          width = nil,
          min_width = 10,
          win_opts = {},
          default_direction = "prefer_right",
          placement = "window",
        },
        attach_mode = "window",
        close_automatic_events = {},
        keymaps = {
          ["?"] = "actions.show_help",
          ["g?"] = "actions.show_help",
          ["<CR>"] = "actions.jump",
          ["<2-LeftMouse>"] = "actions.jump",
          ["<C-v>"] = "actions.jump_vsplit",
          ["<C-s>"] = "actions.jump_split",
          ["p"] = "actions.scroll",
          ["<C-j>"] = "actions.down_and_scroll",
          ["<C-k>"] = "actions.up_and_scroll",
          ["{"] = "actions.prev",
          ["}"] = "actions.next",
          ["[["] = "actions.prev_up",
          ["]]"] = "actions.next_up",
          ["q"] = "actions.close",
          ["o"] = "actions.tree_toggle",
          ["za"] = "actions.tree_toggle",
          ["O"] = "actions.tree_toggle_recursive",
          ["zA"] = "actions.tree_toggle_recursive",
          ["l"] = "actions.tree_open",
          ["zo"] = "actions.tree_open",
          ["L"] = "actions.tree_open_recursive",
          ["zO"] = "actions.tree_open_recursive",
          ["h"] = "actions.tree_close",
          ["zc"] = "actions.tree_close",
          ["H"] = "actions.tree_close_recursive",
          ["zC"] = "actions.tree_close_recursive",
          ["zr"] = "actions.tree_increase_fold_level",
          ["zR"] = "actions.tree_open_all",
          ["zm"] = "actions.tree_decrease_fold_level",
          ["zM"] = "actions.tree_close_all",
          ["zx"] = "actions.tree_sync_folds",
          ["zX"] = "actions.tree_sync_folds",
        },
        show_guides = true,
        filter_kind = false,
        highlight_on_hover = true,
        autojump = false,
        icons = {},
        ignore = {
          unlisted_buffers = true,
          filetypes = { "rust" }, -- rustaceanvim provides its own outline
          buftypes = "special",
          wintypes = "special",
        },
      })
    end,
  },

  -- Flash: Enhanced navigation and search
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function() require("flash").jump() end,
        desc = "Flash Jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function() require("flash").treesitter() end,
        desc = "Flash Treesitter",
      },
      {
        "<leader>fr",
        mode = "o",
        function() require("flash").remote() end,
        desc = "[F]lash [R]emote",
      },
      {
        "<leader>fR",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "[F]lash Treesitter [S]earch",
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc = "Toggle Flash Search",
      },
    },
    opts = {
      labels = "asdfghjklqwertyuiopzxcvbnm",
      search = {
        multi_window = true,
        forward = true,
        wrap = true,
        mode = "exact",
      },
      jump = {
        jumplist = true,
        pos = "start",
        history = false,
        register = false,
        nohlsearch = false,
      },
      label = {
        uppercase = true,
        rainbow = {
          enabled = false,
          shade = 5,
        },
      },
      modes = {
        search = {
          enabled = true,
        },
        char = {
          enabled = true,
          jump_labels = true,
        },
      },
    },
  },

  -- Harpoon: Quick file navigation
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>hm",
        function()
          local harpoon = require("harpoon")
          harpoon:list():add()
          vim.notify("Harpoon: marked " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        end,
        desc = "[H]arpoon [M]ark",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "[H]arpoon Menu",
      },
      {
        "<leader>1",
        function() require("harpoon"):list():select(1) end,
        desc = "Harpoon File 1",
      },
      {
        "<leader>2",
        function() require("harpoon"):list():select(2) end,
        desc = "Harpoon File 2",
      },
      {
        "<leader>3",
        function() require("harpoon"):list():select(3) end,
        desc = "Harpoon File 3",
      },
      {
        "<leader>4",
        function() require("harpoon"):list():select(4) end,
        desc = "Harpoon File 4",
      },
    },
    config = function()
      require("harpoon"):setup({})
    end,
  },

  -- Navic: Code context/location
  {
    "SmiteshP/nvim-navic",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("nvim-navic").setup({
        direction = "left",
        icons = {
          File = "󰈙 ",
          Module = " ",
          Namespace = "󰌗 ",
          Package = " ",
          Class = "󰌗 ",
          Method = "󰆧 ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = "󰕘",
          Interface = "󰕘",
          Function = "󰊕 ",
          Variable = "󰆧 ",
          Constant = "󰏿 ",
          String = "󰀬 ",
          Number = "󰎠 ",
          Boolean = "◩ ",
          Array = "󰅪 ",
          Object = "󰅩 ",
          Key = "󰌋 ",
          Null = "󰟢 ",
          EnumMember = " ",
          Struct = "󰌗 ",
          Event = " ",
          Operator = "󰆕 ",
          TypeParameter = "󰊄 ",
        },
        highlight = true,
        separator = " > ",
        depth_limit = 0,
        depth_limit_indicator = "..",
      })
    end,
  },
}
