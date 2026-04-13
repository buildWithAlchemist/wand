local M = {}

function M.format_time(secs)
  return string.format("%02d:%02d", math.floor(secs / 60), secs % 60)
end

return M
