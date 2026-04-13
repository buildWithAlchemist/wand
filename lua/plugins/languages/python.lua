-- ============================================================================
-- Python Language Support - Molten (Jupyter)
-- ============================================================================

return {
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        force_ft = "markdown",
      })
    end,
    event = "BufReadPre *.ipynb",
  },
  {
    "3rd/image.nvim",
    build = false,
    enabled = function()
      local term = vim.env.TERM or ""
      local supports_backend = term:match("kitty")
      return supports_backend ~= nil and vim.fn.executable("magick") == 1
    end,
    config = function()
      local ok, image = pcall(require, "image")
      if not ok then
        return
      end
      local setup_ok, _ = pcall(image.setup, {
        processor = "magick_cli",
        backend = "kitty",
        integrations = {},
        max_height = 12,
        max_width = 100,
        max_width_window_percentage = math.huge,
        max_height_window_percentage = math.huge,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      })
      if not setup_ok then
        return
      end
    end
  },
  {
    "benlubas/molten-nvim",
    build = function()
      pcall(vim.cmd, "UpdateRemotePlugins")
    end,
    ft = { "python", "markdown" },
    config = function()
      -- Set Python host for remote plugins (Molten requires pynvim)
      -- Auto-detect project venv or fall back to system Python
      local project_venv = vim.fn.findfile(".venv/bin/python", ".;")
      if project_venv ~= "" then
        vim.g.python3_host_prog = vim.fn.fnamemodify(project_venv, ":p")
      elseif vim.fn.executable("python3") == 1 then
        vim.g.python3_host_prog = vim.fn.exepath("python3")
      end

      -- Molten configuration
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true -- Auto-show output
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true

      -- Cell markers: Define what marks the start of a cell
      -- Supports: # %%, # <codecell>, and markdown cells
      vim.g.molten_use_border_highlights = true
      vim.g.molten_enter_output_behavior = "open_then_enter" -- or "open_and_enter"

      -- Auto-initialize Molten for .ipynb files
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*.ipynb",
        callback = function(ev)
          -- Wait a moment for jupytext to convert the file
          vim.defer_fn(function()
            -- Check if buffer already has a kernel attached
            local bufnr = ev.buf
            local kernels = vim.fn.MoltenAvailableKernels()
            local has_kernel = false

            -- Check if this buffer already has a kernel
            if kernels and #kernels > 0 then
              -- Try to detect if buffer is already initialized
              local ok, _ = pcall(vim.api.nvim_buf_get_var, bufnr, "molten_initialized")
              if ok then
                has_kernel = true
              end
            end

            -- Only initialize if no kernel is attached to this buffer
            if not has_kernel then
              vim.cmd("silent! MoltenInit python3")
              -- Mark buffer as initialized
              vim.api.nvim_buf_set_var(bufnr, "molten_initialized", true)
            end
          end, 100)
        end,
      })
    end,
    keys = {
      { "<leader>mi", ":MoltenInit python3<CR>",          desc = "Initialize Molten" },
      { "<leader>me", ":MoltenEvaluateOperator<CR>",      desc = "Evaluate operator" },
      { "<leader>mr", ":MoltenReevaluateCell<CR>",        desc = "Re-evaluate cell" },
      { "<leader>ml", ":MoltenEvaluateLine<CR>",          desc = "Evaluate line" },
      { "<leader>mv", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v",                       desc = "Evaluate visual" },
      { "<leader>md", ":MoltenDelete<CR>",                desc = "Delete cell" },
      { "<leader>mo", ":MoltenHideOutput<CR>",            desc = "Hide output" },
      { "<leader>ms", ":noautocmd MoltenEnterOutput<CR>", desc = "Show/enter output" },
      -- Kernel management
      { "<leader>mD", ":MoltenDeinit<CR>",                desc = "Deinitialize/stop kernel" },
      { "<leader>mI", ":MoltenInfo<CR>",                  desc = "Show kernel info" },
      -- Navigation
      { "]m",         ":MoltenNext<CR>",                  desc = "Next [m]olten cell",      ft = "python" },
      { "[m",         ":MoltenPrev<CR>",                  desc = "Previous [m]olten cell",  ft = "python" },
     },
   },
   {
     "mfussenegger/nvim-dap-python",
     ft = "python",
     config = function()
       require("dap-python").setup("python")
     end,
   },
   -- neotest-python is listed as a neotest dependency in testing.lua
 }
