local M = {}

local _timer = nil
local _running = false

--- Start a repeating poll timer.
---@param interval_ms number milliseconds between ticks
---@param on_tick fun() called on each interval
function M.start(interval_ms, on_tick)
  M.stop()
  _timer = vim.uv.new_timer()
  _running = true
  _timer:start(interval_ms, interval_ms, function()
    vim.schedule(function()
      if not _running then return end
      local ok, err = pcall(on_tick)
      if not ok then
        vim.notify("Pomodoro poll error: " .. tostring(err), vim.log.levels.ERROR)
      end
    end)
  end)
end

--- Stop the timer. Idempotent.
function M.stop()
  if _timer then
    _timer:stop()
    _timer:close()
    _timer = nil
  end
  _running = false
end

---@return boolean
function M.is_running()
  return _running
end

return M
