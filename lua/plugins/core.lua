-- ============================================================================
-- Core Plugins - Essential functionality
-- ============================================================================

return {
  {
    "NStefan002/screenkey.nvim",
    cmd = "Screenkey",
    version = "*",
  },
  -- Which-key: Shows keybinding popups
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function() end,
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "helix",
        win = {
          border = "single",
        },
      })

      -- Register group names with icons
      wk.add({
        { "<leader>a", group = "󰚩 [A]I Assistant", icon = "🤖" },
        { "<leader>an", group = "󰎞 [N]otion", icon = "📝" },
        { "<leader>b", group = "󰓩 [B]uffer", icon = "📄" },
        { "<leader>c", group = "󰘦 [C]ode/Commands", icon = "⚡" },
        { "<leader>d", group = "󰃤 [D]ebug", icon = "🐛" },
        { "<leader>f", group = "󰍉 [F]ind/File", icon = "🔍" },
        { "<leader>g", group = "󰊢 [G]it", icon = "" },
        { "<leader>h", group = "󰛢 [H]arpoon", icon = "⚓" },
        { "<leader>l", group = "󰘦 [L]SP", icon = "🔧" },
        { "<leader>m", group = "󰌠 [M]olten (Jupyter)", icon = "🧪" },
        { "<leader>o", group = "󰫦 [O]utline", icon = "📋" },
        { "<leader>p", group = "󱎫 [P]omodoro", icon = "🔥" },
        { "<leader>n", group = "󰍡 [N]otes/Notify", icon = "🔔" },
        { "<leader>q", group = "󰗼 [Q]uit", icon = "🚪" },
        { "<leader>r", group = "󰑕 [R]efactor", icon = "🔄" },
        { "<leader>s", group = "󰛔 [S]earch/Replace", icon = "🔎" },
        { "<leader>t", group = "󰙨 [T]est/Tab/Terminal", icon = "🧪" },
        { "<leader>u", group = "󰃣 [U]I", icon = "🎨" },
        { "<leader>w", group = "󰨭 [W]indow", icon = "⚠️" },
        { "<leader>x", group = "󰨭 [X] Diagnostics", icon = "⚠️" },
      })
    end,
  },

  -- Plenary: Lua utility library (required by many plugins)
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Nui: UI component library (required by noice, etc.)
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },

  -- Web devicons: File icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Snacks: Swiss-army knife (replaces nvim-notify, dressing, toggleterm,
  -- indent-blankline, mini.indentscope, mini.animate, lazygit, zen-mode, twilight)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- Scratch
      { "<leader>ns", function() Snacks.scratch() end,                                                                          desc = "[N]otes [S]cratch" },
      { "<leader>nS", function() Snacks.scratch.select() end,                                                                   desc = "[N]otes [S]cratch Select" },
      -- Notifications
      { "<leader>fn", function() Snacks.notifier.show_history() end,                                                            desc = "[F]ind [N]otifications" },
      { "<leader>nd", function() Snacks.notifier.hide() end,                                                                    desc = "[N]otification [D]ismiss All" },
      -- Terminal
      { "<C-/>",      function() Snacks.terminal.toggle(vim.o.shell) end,                                                       desc = "Toggle Terminal",             mode = { "n", "t" } },
      { "<leader>tf", function() Snacks.terminal.toggle(vim.o.shell, { win = { style = "terminal", position = "float" } }) end, desc = "[T]erminal [F]loat" },
      {
        "<leader>th",
        function()
          Snacks.terminal.toggle(vim.o.shell,
            { win = { style = "terminal", position = "bottom", height = 15 } })
        end,
        desc = "[T]erminal [H]orizontal"
      },
      {
        "<leader>tv",
        function()
          Snacks.terminal.toggle(vim.o.shell,
            { win = { style = "terminal", position = "right", width = 80 } })
        end,
        desc = "[T]erminal [V]ertical"
      },
      { "<leader>tp", function() Snacks.terminal.toggle("python3", { win = { style = "terminal", position = "float" } }) end, desc = "[T]erminal [P]ython" },
      { "<leader>tn", function() Snacks.terminal.toggle("node", { win = { style = "terminal", position = "float" } }) end,    desc = "[T]erminal [N]ode" },
      -- Lazygit
      { "<leader>gg", function() Snacks.lazygit() end,                                                                        desc = "[G]it UI" },
      { "<leader>gf", function() Snacks.lazygit.log_file() end,                                                               desc = "[G]it Current [F]ile" },
      -- Zen mode
      { "<leader>z",  function() Snacks.zen() end,                                                                            desc = "[Z]en Mode" },
      -- Dim (twilight replacement)
      {
        "<leader>uT",
        function()
          if Snacks.dim.enabled then Snacks.dim.disable() else Snacks.dim() end
        end,
        desc = "[U]I [T]wilight/Dim"
      },
      -- Git browse
      { "<leader>gB", function() Snacks.gitbrowse() end,          desc = "[G]it [B]rowse" },
      -- LSP words (reference navigation)
      { "]r",         function() Snacks.words.jump(1) end,        desc = "Next [R]eference" },
      { "[r",         function() Snacks.words.jump(-1) end,       desc = "Prev [R]eference" },
      -- Rename
      { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "[C]ode [R]ename File" },
      -- Buffer delete
      { "<leader>bd", function() Snacks.bufdelete() end,          desc = "[B]uffer [D]elete" },
      { "<leader>bD", function() Snacks.bufdelete.other() end,    desc = "[B]uffer [D]elete Others" },
      {
        "<leader>bw",
        function()
          vim.cmd("w"); Snacks.bufdelete()
        end,
        desc = "[B]uffer [W]rite & Delete"
      },
    },
    opts = {
      scratch = {
        ft = "markdown",
      },
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            "",
            " ██████╗████████╗██████╗ ██╗          █████╗ ██╗  ████████╗    ████████╗███████╗ ██████╗██╗  ██╗",
            "██╔════╝╚══██╔══╝██╔══██╗██║         ██╔══██╗██║  ╚══██╔══╝    ╚══██╔══╝██╔════╝██╔════╝██║  ██║",
            "██║        ██║   ██████╔╝██║         ███████║██║     ██║          ██║   █████╗  ██║     ███████║",
            "██║        ██║   ██╔══██╗██║         ██╔══██║██║     ██║          ██║   ██╔══╝  ██║     ██╔══██║",
            "╚██████╗   ██║   ██║  ██║███████╗    ██║  ██║███████╗██║          ██║   ███████╗╚██████╗██║  ██║",
            " ╚═════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═╝          ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝",
            "",
          }, "\n"),
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "p", desc = "Projects", action = ":Telescope projects" },
            { icon = " ", key = "c", desc = "Configuration", action = ":edit $MYVIMRC" },
            { icon = "󰒲 ", key = "u", desc = "Update Plugins", action = ":Lazy update" },
            { icon = " ", key = "q", desc = "Quit", action = ":quit" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys",   gap = 1, padding = 3 },
          { section = "startup" },
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "fancy",
      },
      input = {
        enabled = true,
      },
      terminal = {
        win = {
          style = "terminal",
          position = "bottom",
          border = "single",
          height = 15,
        },
        shell = vim.o.shell,
      },
      lazygit = {
        enabled = true,
        win = {
          position = "float",
          width = 0.85,
          height = 0.85,
        },
      },
      zen = {
        enabled = true,
        toggles = {
          dim = true,
          git_signs = false,
        },
      },
      dim = {
        enabled = true,
      },
      indent = {
        enabled = true,
        indent = {
          char = "│",
        },
        scope = {
          enabled = true,
          char = "│",
        },
      },
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 10, total = 200 },
          easing = "linear",
        },
      },
      animate = {
        enabled = true,
      },
      bigfile = {
        enabled = true,
        size = 1.5 * 1024 * 1024, -- 1.5MB
        notify = true,
      },
      words = {
        enabled = true,
      },
      gitbrowse = {
        enabled = true,
      },
      rename = {
        enabled = true,
      },
      picker = {},
    },
    init = function()
      -- Terminal keymaps (must be set outside of snacks config)
      vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
      vim.keymap.set("t", "<C-q>", [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
    end,
  },
}
