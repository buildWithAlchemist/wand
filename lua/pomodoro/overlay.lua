local M = {}

local _win = nil
local _timer = nil
local _callbacks = nil
local _remaining = 0

local format_time = require("pomodoro.util").format_time

local function center_pad(text)
  local width = vim.o.columns or 80
  local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
  return string.rep(" ", pad) .. text
end

---@return boolean
function M.is_open()
  return _win ~= nil and not _win.closed
end

--- Close the overlay and its internal timer. Idempotent.
--- Does NOT fire on_complete or on_stop callbacks — raw teardown only.
function M.close()
  if _timer then
    _timer:stop()
    _timer:close()
    _timer = nil
  end
  if _win and not _win.closed then
    _win:close()
  end
  _win = nil
  _callbacks = nil
end

--- Update the display lines in the overlay buffer.
---@param buf number buffer handle
---@param title string e.g. "Short Break — Cycle 2/4"
local function update_display(buf, title)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local lines = {
    "",
    center_pad(title),
    "",
    center_pad(format_time(_remaining)),
    "",
    center_pad("Type 'stop' to end the session"),
  }
  vim.api.nvim_buf_set_lines(buf, 0, -2, false, lines)
end

--- Open the full-screen break overlay.
---@param opts { title: string, duration_secs: number, cycle_info: string }
---@param callbacks { on_complete: fun(), on_stop: fun(), on_tick: fun(remaining: number)? }
function M.open(opts, callbacks)
  if M.is_open() then
    M.close()
  end

  _remaining = opts.duration_secs
  _callbacks = callbacks

  -- Create prompt buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "prompt"
  vim.bo[buf].bufhidden = "wipe"
  vim.fn.prompt_setprompt(buf, "▸ ")

  -- Prevent E162 "No write since last change" by keeping buffer unmodified
  vim.api.nvim_create_autocmd("BufModifiedSet", {
    group = vim.api.nvim_create_augroup("PomodoroOverlayModified_" .. buf, { clear = true }),
    buffer = buf,
    callback = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.bo[buf].modified = false
      end
    end,
  })

  -- Initial display lines
  local title = opts.title .. " — " .. opts.cycle_info
  local info_lines = {
    "",
    center_pad(title),
    "",
    center_pad(format_time(_remaining)),
    "",
    center_pad("Type 'stop' to end the session"),
  }
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, info_lines)

  -- Prompt callback: only accept "stop"
  vim.fn.prompt_setcallback(buf, function(input)
    local trimmed = vim.trim(input):lower()
    if trimmed == "stop" then
      local cb = _callbacks and _callbacks.on_stop
      M.close()
      if cb then cb() end
    else
      vim.notify("Type 'stop' to end the session", vim.log.levels.WARN)
    end
  end)

  -- Block navigation, scrolling, and window-switching keys
  local block_normal = { "k", "j", "<Up>", "<Down>", "gg", "G", "<C-w>", "<C-u>", "<C-d>", "<C-f>", "<C-b>", "<ScrollWheelUp>", "<ScrollWheelDown>", "<LeftMouse>", "<RightMouse>" }
  for _, key in ipairs(block_normal) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, "", { noremap = true, silent = true })
  end
  local block_insert = { "<Up>", "<Down>", "<C-w>", "<ScrollWheelUp>", "<ScrollWheelDown>", "<LeftMouse>", "<RightMouse>" }
  for _, key in ipairs(block_insert) do
    vim.api.nvim_buf_set_keymap(buf, "i", key, "", { noremap = true, silent = true })
  end

  -- Store title for display updates
  local display_title = title

  -- Open full-screen via Snacks.win
  _win = Snacks.win({
    buf = buf,
    position = "float",
    width = 1.0,
    height = 1.0,
    border = "none",
    title = " Pomodoro Break ",
    title_pos = "center",
    enter = true,
    on_close = function()
      -- Stop timer on close to prevent leaks
      if _timer then
        _timer:stop()
        _timer:close()
        _timer = nil
      end
      _win = nil
      _callbacks = nil
    end,
  })

  local win_id = _win.win

  vim.cmd("startinsert")

  -- Force user back to insert mode if they escape (prevents editing info lines)
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = vim.api.nvim_create_augroup("PomodoroOverlayInsert_" .. buf, { clear = true }),
    buffer = buf,
    callback = function()
      if M.is_open() then
        vim.schedule(function()
          if M.is_open() and vim.api.nvim_buf_is_valid(buf) then
            vim.cmd("startinsert")
          end
        end)
      end
    end,
  })

  -- Recapture focus if user switches to another window
  local overlay_group = vim.api.nvim_create_augroup("PomodoroOverlayRecapture_" .. buf, { clear = true })
  vim.api.nvim_create_autocmd("WinEnter", {
    group = overlay_group,
    callback = function()
      if M.is_open() and vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_get_current_win() ~= win_id then
        vim.api.nvim_set_current_win(win_id)
        vim.cmd("startinsert")
      end
      -- Clean up autocmd when overlay is gone
      if not M.is_open() then
        return true
      end
    end,
  })

  -- Start internal countdown timer
  _timer = vim.uv.new_timer()
  _timer:start(1000, 1000, function()
    _remaining = _remaining - 1
    vim.schedule(function()
      -- Guard: already closed by a prior tick or external close
      if not _timer then return end

      if _callbacks and _callbacks.on_tick then
        pcall(_callbacks.on_tick, _remaining)
      end

      -- Update display
      if M.is_open() and vim.api.nvim_buf_is_valid(buf) then
        pcall(update_display, buf, display_title)
      end

      if _remaining <= 0 then
        local cb = _callbacks and _callbacks.on_complete
        M.close()
        if cb then
          local ok, err = pcall(cb)
          if not ok then
            vim.notify("Pomodoro overlay complete error: " .. tostring(err), vim.log.levels.ERROR)
          end
        end
      end
    end)
  end)
end

return M
