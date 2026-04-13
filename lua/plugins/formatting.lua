-- ============================================================================
-- Formatting - Conform.nvim
-- ============================================================================

return {
  -- Conform.nvim: Lightweight yet powerful formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "v" },
        desc = "[L]SP [F]ormat",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        scss = { "prettierd", "prettier", stop_after_first = true },
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        sql = { "sql_formatter" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat or vim.b[bufnr].skip_save_hooks then
          return
        end
        -- Skip formatting for large files (>500KB)
        local filepath = vim.fn.expand("%:p")
        if filepath ~= "" then
          local filesize = vim.fn.getfsize(filepath)
          if filesize > 512 * 1024 then  -- 500KB
            return
          end
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    init = function()
      -- If you want the formatexpr, here is the place to set it
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      -- Commands to toggle format on save
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
  },
  -- Mason Tool Installer: Auto-install formatters and linters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    lazy = false,
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          -- LSP servers
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
          -- Formatters and linters
          "stylua",
          "isort",
          "black",
          "prettierd",
          "prettier",
          "eslint_d",
          "markdownlint-cli2",
          "goimports",
          "rustfmt",
          "shfmt",
          "sql-formatter",
        },
        run_on_start = true,
        start_delay = 3000,
        debounce_hours = 12,
        integrations = {
          ["mason-lspconfig"] = true,
        },
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        python = { "ruff" },
        markdown = { "markdownlint-cli2" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("MadEngineerLint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
