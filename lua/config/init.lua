-- Load global variables management
require("globals")

-- Buffer early notifications and replay them once noice (or another plugin)
-- takes over vim.notify. Without this, mason/treesitter install messages on
-- fresh install appear as raw bottom-bar messages instead of routing through noice.
-- Pattern from LazyVim: https://github.com/LazyVim/LazyVim
local function lazy_notify()
  local notifs = {}
  local replayed = false
  local orig = vim.notify
  vim.notify = function(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local timer = vim.uv.new_timer()
  local check = vim.uv.new_check()

  local function replay()
    if replayed then return end
    replayed = true
    timer:stop()
    check:stop()
    if not timer:is_closing() then timer:close() end
    if not check:is_closing() then check:close() end
    -- Only replay if vim.notify was replaced by a plugin (noice/nvim-notify)
    if vim.notify ~= orig then
      local current = vim.notify
      vim.schedule(function()
        for _, notif in ipairs(notifs) do
          current(vim.F.unpack_len(notif))
        end
      end)
    end
  end

  -- Poll every event loop tick: detect when a plugin replaces vim.notify.
  -- snacks.notifier (lazy=false, priority=1000) takes over almost immediately.
  check:start(function()
    if vim.notify ~= orig then
      replay()
    end
  end)

  -- Safety: stop buffering after 500ms even if nothing replaced vim.notify
  timer:start(500, 0, replay)
end

lazy_notify()

-- Load all configuration modules in order
require("config.options")
require("config.autocmds")
require("config.keymaps")
require("config.languages")
