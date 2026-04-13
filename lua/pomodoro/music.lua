local M = {}

--- Resume playback or launch YouTube Music if no player is running.
function M.play()
  vim.fn.jobstart({ "playerctl", "play" }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.fn.jobstart({ "xdg-open", "https://music.youtube.com" }, { detach = true })
          vim.notify("🎵 Focus music started!", vim.log.levels.INFO)
        end
      end)
    end,
  })
end

--- Pause playback. Fails silently if no player is running.
function M.pause()
  vim.fn.jobstart({ "playerctl", "pause" })
end

return M
