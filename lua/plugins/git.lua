-- ============================================================================
-- Git Integration - Lazygit, Gitsigns
-- ============================================================================

return {
  -- Lazygit: handled by snacks.lazygit (see core.lua)

  -- Gitsigns: Git decorations and hunks
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
          untracked = { text = "┆" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            if opts.noremap == nil then opts.noremap = true end
            if opts.silent == nil then opts.silent = true end
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map("n", "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Next Hunk" })

          map("n", "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Prev Hunk" })

          -- Actions
          map("n", "<leader>ghs", gs.stage_hunk, { desc = "[H]unk [S]tage" })
          map("n", "<leader>ghr", gs.reset_hunk, { desc = "[H]unk [R]eset" })
          map("v", "<leader>ghs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "[H]unk [S]tage" })
          map("v", "<leader>ghr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "[H]unk [R]eset" })
          map("n", "<leader>ghS", gs.stage_buffer, { desc = "[H]unk [S]tage Buffer" })
          map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "[H]unk [U]ndo Stage" })
          map("n", "<leader>ghR", gs.reset_buffer, { desc = "[H]unk [R]eset Buffer" })
          map("n", "<leader>ghp", gs.preview_hunk, { desc = "[H]unk [P]review" })
          map("n", "<leader>ghb", function()
            gs.blame_line({ full = true })
          end, { desc = "[H]unk [B]lame Line" })
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "[T]oggle [B]lame" })
          map("n", "<leader>ghd", gs.diffthis, { desc = "[H]unk [D]iff" })
          map("n", "<leader>ghD", function()
            gs.diffthis("~")
          end, { desc = "[H]unk [D]iff ~" })
          map("n", "<leader>gd", gs.toggle_deleted, { desc = "[G]it Toggle [D]eleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select Hunk" })
        end,
      })
    end,
  },
}
