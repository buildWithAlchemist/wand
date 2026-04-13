-- ============================================================================
-- AI Assistant - Sidekick.nvim
-- ============================================================================

return {
  -- Sidekick: Your Neovim AI sidekick
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-treesitter/nvim-treesitter-textobjects", -- Optional but recommended
    },
    keys = {
      -- CLI terminal toggle
      { "<C-.>",       "<cmd>Sidekick cli toggle<cr>",                                          desc = "Toggle AI CLI Terminal" },

      -- AI CLI actions
      { "<leader>aa",  "<cmd>Sidekick cli toggle<cr>",                                          desc = "[A]I CLI Tools" },
      { "<leader>al",  "<cmd>Sidekick cli select<cr>",                                          desc = "[A]I Se[l]ect CLI Tool" },
      { "<leader>ad",  "<cmd>Sidekick cli detach<cr>",                                          desc = "[A]I [D]etach Session" },

      -- Send to AI
      { "<leader>aS",  "<cmd>Sidekick cli send<cr>",                                            mode = { "n", "v" },                 desc = "[A]I [S]end Text" },
      { "<leader>af",  "<cmd>Sidekick cli send-file<cr>",                                       desc = "[A]I Send [F]ile" },

      -- Prompts
      { "<leader>ap",  "<cmd>Sidekick cli prompt<cr>",                                          mode = { "n", "v" },                 desc = "[A]I [P]rompt" },
      { "<leader>ae",  "<cmd>Sidekick cli prompt explain<cr>",                                  mode = { "n", "v" },                 desc = "[A]I [E]xplain" },
      { "<leader>ax",  "<cmd>Sidekick cli prompt fix<cr>",                                      mode = { "n", "v" },                 desc = "[A]I Fi[x]" },
      { "<leader>ao",  "<cmd>Sidekick cli prompt optimize<cr>",                                 mode = { "n", "v" },                 desc = "[A]I [O]ptimize" },
      { "<leader>aD",  "<cmd>Sidekick cli prompt document<cr>",                                 mode = { "n", "v" },                 desc = "[A]I [D]ocument" },
      { "<leader>aT",  "<cmd>Sidekick cli prompt tests<cr>",                                    mode = { "n", "v" },                 desc = "[A]I [T]ests" },
      { "<leader>ar",  "<cmd>Sidekick cli prompt review<cr>",                                   mode = { "n", "v" },                 desc = "[A]I [R]eview" },
      { "<leader>ai",  "<cmd>Sidekick cli prompt diagnostics<cr>",                              desc = "[A]I D[i]agnostics" },

      -- Notion prompts (keybinding-only, bypass picker to allow vim.fn.input)
      { "<leader>ans", function() require("plugins.prompts.notion").notion_search() end,        desc = "[A]I [N]otion [S]earch" },
      { "<leader>ant", function() require("plugins.prompts.notion").notion_today() end,         desc = "[A]I [N]otion [T]oday" },
      { "<leader>ann", function() require("plugins.prompts.notion").notion_quick_note() end,    desc = "[A]I [N]otion Quick [N]ote" },

      -- Jira prompts (keybinding-only, bypass picker to allow vim.fn.input)
      { "<leader>ajm", function() require("plugins.prompts.jira").jira_my_tickets() end,        desc = "[A]I [J]ira [M]y Tickets" },
      { "<leader>ajb", function() require("plugins.prompts.jira").jira_create_branch() end,     desc = "[A]I [J]ira Create [B]ranch" },

      -- Session prompts
      { "<leader>ass", function() require("plugins.prompts.jira").session_start() end,          desc = "[A]I [S]ession [S]tart" },
      { "<leader>ase", function() require("plugins.prompts.jira").session_end() end,            desc = "[A]I [S]ession [E]nd" },

      -- Task prompts
      { "<leader>ats", function() require("plugins.prompts.jira").task_start() end,             desc = "[A]I [T]ask [S]tart" },
      { "<leader>ate", function() require("plugins.prompts.jira").task_end() end,               desc = "[A]I [T]ask [E]nd" },

      -- Coding prompts (Serena-powered)
      { "<leader>acr", function() require("plugins.prompts.coding").code_review() end,          mode = { "n", "v" },                 desc = "[A]I [C]ode [R]eview" },
      { "<leader>abr", function() require("plugins.prompts.coding").blast_radius() end,         mode = { "n", "v" },                 desc = "[A]I [B]last [R]adius" },

      -- Krisp meeting prompts
      { "<leader>akr", function() require("plugins.prompts.krisp").meeting_review() end,        desc = "[A]I [K]risp [R]eview" },

      -- Thinking prompts
      { "<leader>aAd", function() require("plugins.prompts.general").architecture_debate() end, mode = { "n", "v" },                 desc = "[A]I [A]rch [D]ebate" },
      { "<leader>avc", function() require("plugins.prompts.general").verify_conventions() end,  desc = "[A]I [V]erify [C]onventions" },
      { "<leader>ayi", function() require("plugins.prompts.general").youtube_idea() end,        desc = "[A]I [Y]ouTube [I]dea" },

      -- Next Edit Suggestions navigation
      { "<Tab>",       desc = "Navigate/Apply NES" }, -- Tab to navigate and apply suggestions
    },
    opts = {
      -- Next Edit Suggestions (NES) powered by Copilot LSP
      nes = {
        enabled = true,     -- Enable automatic edit suggestions
        debounce = 100,     -- Delay before fetching suggestions (ms)
        diff = {
          inline = "words", -- Inline diff granularity: "words" or "chars"
        },
      },

      -- AI CLI Integration
      cli = {
        enabled = true,
        watch = true, -- Auto-watch files for changes

        -- Window layout
        win = {
          layout = "right", -- "right", "left", "top", "bottom", "float"
          split = {
            width = 80,     -- Width for vertical splits
            height = 20,    -- Height for horizontal splits
          },
        },

        -- Terminal multiplexer integration (tmux/zellij)
        mux = {
          enabled = false,  -- Set to true if using tmux/zellij
          backend = "tmux", -- "tmux" or "zellij"
        },

      },

      -- Statusline integration (shows NES status)
      statusline = {
        enabled = true,
      },
    },
    config = function(_, opts)
      -- Merge Notion picker prompts into opts before setup
      -- (deferred require — opts.cli.prompts is merged with built-in prompts
      -- by sidekick's vim.tbl_deep_extend in setup())
      opts.cli = opts.cli or {}
      local all_prompts = {}
      local modules = {
        require("plugins.prompts.notion").prompts,
        require("plugins.prompts.jira").prompts,
        require("plugins.prompts.krisp").prompts,
        require("plugins.prompts.coding").prompts,
        require("plugins.prompts.general").prompts,
      }
      for _, mod in ipairs(modules) do
        for k, v in pairs(mod) do
          assert(all_prompts[k] == nil, "Sidekick prompt key collision: " .. k)
          all_prompts[k] = v
        end
      end
      opts.cli.prompts = all_prompts

      require("sidekick").setup(opts)

      -- Check Copilot authentication after startup
      vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("SidekickCopilotCheck", { clear = true }),
        once = true,
        callback = function()
          vim.defer_fn(function()
            local ok = vim.fn.exists(":Copilot") == 2
            if not ok then
              vim.notify(
                "Sidekick.nvim: Copilot not loaded — run :Copilot auth to authenticate",
                vim.log.levels.INFO
              )
            end
          end, 1000)
        end,
      })
    end,
  },
}
