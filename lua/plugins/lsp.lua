-- ============================================================================
-- LSP Configuration - Mason, lspconfig, treesitter
-- ============================================================================

return {
  -- LazyDev: Proper Lua LSP setup for Neovim config development
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luv types when vim.uv is referenced
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Load lazy.nvim types
        { path = "lazy.nvim",          words = { "lazy" } },
      },
      integrations = {
        lspconfig = true, -- Automatically configures lua_ls
        cmp = false,      -- Disabled: we use blink.cmp (see completion.lua)
      },
    },
  },

  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "[C]ode [M]ason" } },
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "single",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
      })
    end,
  },

  -- Mason-lspconfig: Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      -- Defer mason-lspconfig setup to let UI render first on fresh install.
      -- Early notifications are buffered by lazy_notify() in config/init.lua
      -- and replayed through noice once it loads.
      vim.defer_fn(function()
        local blink_ok, blink = pcall(require, "blink.cmp")
        local capabilities = blink_ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

        -- Shared on_attach: attaches navic for code context breadcrumbs
        local function on_attach(client, bufnr)
          if client.server_capabilities.documentSymbolProvider then
            require("nvim-navic").attach(client, bufnr)
          end
        end

        require("mason-lspconfig").setup({
          ensure_installed = {
            "lua_ls",
            "ruff",
            "pyright",
            "ts_ls",
            "gopls",
            "rust_analyzer",
            "sqlls",
            "marksman",
            "dockerls",
            "bashls",
          },
          automatic_installation = true,
          handlers = {
            -- Default handler for all servers
            function(server_name)
              local lsp = require("lspconfig")[server_name]
              if not lsp then
                vim.notify("LSP: unknown server '" .. server_name .. "'", vim.log.levels.WARN)
                return
              end
              lsp.setup({
                capabilities = capabilities,
                on_attach = on_attach,
              })
            end,
            -- Custom handlers for specific servers
            ["lua_ls"] = function()
              require("lspconfig").lua_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = { "vim" },
                    },
                    -- workspace library managed by lazydev.nvim
                    telemetry = {
                      enable = false,
                    },
                  },
                },
              })
            end,
            ["pyright"] = function()
              require("lspconfig").pyright.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                  python = {
                    analysis = {
                      typeCheckingMode = "basic",
                      autoSearchPaths = true,
                      useLibraryCodeForTypes = true,
                    },
                  },
                },
              })
            end,
            ["ts_ls"] = function()
              require("lspconfig").ts_ls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                init_options = {
                  hostInfo = "neovim",
                },
              })
            end,
            ["gopls"] = function()
              require("lspconfig").gopls.setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = {
                  gopls = {
                    analyses = {
                      unusedparams = true,
                    },
                    staticcheck = true,
                  },
                },
              })
            end,
          },
        })

        -- Re-trigger FileType for already-open buffers so LSP attaches after deferred setup
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= "" then
            vim.api.nvim_exec_autocmds("FileType", { buffer = buf })
          end
        end
      end, 100)
    end,
  },

  -- LSP config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Disable Neovim's default LSP keymaps (grr, gra, grn, gri, gO, grt)
      -- We define our own below in LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("MadEngineerLspAttach", { clear = true }),
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          -- Skip setting up keymaps for Copilot LSP (it's handled by Sidekick)
          if client and client.name == "copilot" then
            return
          end

          -- Remove default LSP keymaps
          pcall(vim.keymap.del, "n", "grr", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "gra", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "grn", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "gri", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "gO", { buffer = bufnr })
          pcall(vim.keymap.del, "n", "grt", { buffer = bufnr })

          -- Custom LSP keymaps
          local function desc(description)
            return { buffer = bufnr, noremap = true, silent = true, desc = description }
          end
          local keymap = vim.keymap.set

          -- Documentation
          keymap("n", "K", function()
            local ufo_ok, ufo = pcall(require, "ufo")
            if ufo_ok then
              local winid = ufo.peekFoldedLinesUnderCursor()
              if winid then return end
            end
            vim.lsp.buf.hover()
          end, desc("Hover Documentation / Peek Fold"))
          keymap("n", "<leader>ls", vim.lsp.buf.signature_help, desc("[L]SP [S]ignature Help"))

          -- Navigation
          keymap("n", "gd", "<cmd>Telescope lsp_definitions<cr>", desc("Go to [D]efinition"))
          keymap("n", "gD", vim.lsp.buf.declaration, desc("Go to [D]eclaration"))
          keymap("n", "gr", "<cmd>Telescope lsp_references<cr>", desc("Go to [R]eferences"))
          keymap("n", "gi", "<cmd>Telescope lsp_implementations<cr>", desc("Go to [I]mplementation"))
          keymap("n", "<leader>D", "<cmd>Telescope lsp_type_definitions<cr>", desc("Type [D]efinition"))

          -- Code actions
          keymap("n", "<leader>ca", vim.lsp.buf.code_action, desc("[C]ode [A]ction"))
          keymap("n", "<leader>rn", vim.lsp.buf.rename, desc("[R]e[n]ame"))

          -- Workspace management
          keymap("n", "<leader>la", vim.lsp.buf.add_workspace_folder, desc("[L]SP Workspace [A]dd Folder"))
          keymap("n", "<leader>lr", vim.lsp.buf.remove_workspace_folder, desc("[L]SP Workspace [R]emove Folder"))
          keymap("n", "<leader>ll", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, desc("[L]SP Workspace [L]ist Folders"))
        end,
      })

      -- Diagnostic settings
      vim.diagnostic.config({
        virtual_text = {
          prefix = "●",
          source = "if_many",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          source = "if_many",
          border = "single",
        },
      })

      -- Note: LSP servers are configured via mason-lspconfig handlers above
    end,
  },

  -- Treesitter: Better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local treesitter = require("nvim-treesitter")
      treesitter.setup({})

      local ensure_installed = {
        "bash", "c", "lua", "vim", "vimdoc",
        "python", "typescript", "tsx", "javascript",
        "go", "rust", "sql", "json", "yaml", "toml",
        "markdown", "markdown_inline", "html", "css",
        "regex", "query", "dockerfile",
      }

      local installed = treesitter.get_installed()
      local installed_set = {}
      for _, lang in ipairs(installed) do
        installed_set[lang] = true
      end

      local missing = {}
      for _, lang in ipairs(ensure_installed) do
        if not installed_set[lang] then
          table.insert(missing, lang)
        end
      end

      if #missing > 0 and vim.v.vim_did_enter == 1 then
        vim.notify("Installing " .. #missing .. " treesitter parsers...", vim.log.levels.INFO)
        vim.cmd("TSInstall " .. table.concat(missing, " "))
      end
    end,
  },

  -- Treesitter context: Show code context
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("treesitter-context").setup({
        enable = true,
        max_lines = 3,
        trim_scope = "outer",
        mode = "cursor",
      })
    end,
  },
}
