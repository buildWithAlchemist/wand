-- Utility functions for saving files
local M = {}

-- Check if file is large (>500KB threshold for safety)
local function is_large_file()
  local filepath = vim.fn.expand('%:p')
  if filepath == '' then return false end
  local filesize = vim.fn.getfsize(filepath)
  return filesize > 512 * 1024  -- 500KB threshold
end

-- Async save for large files using libuv
M.async_save = function()
  local buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local filename = vim.fn.expand('%:p')
  if filename == '' then return end
  local data = table.concat(lines, '\n') .. '\n'
  vim.uv.fs_open(filename, 'w', 438, function(err_open, fd)
    if err_open or not fd then
      vim.schedule(function()
        vim.notify("Failed to save file: " .. (err_open or "unknown error"), vim.log.levels.ERROR)
      end)
      return
    end
    vim.uv.fs_write(fd, data, 0, function(err_write)
      vim.uv.fs_close(fd)
      vim.schedule(function()
        if err_write then
          vim.notify("Failed to write file: " .. err_write, vim.log.levels.ERROR)
        elseif vim.api.nvim_buf_is_valid(buf) then
          vim.bo[buf].modified = false
          -- Fire BufWritePost so gitsigns and other plugins refresh
          vim.api.nvim_exec_autocmds("BufWritePost", { buffer = buf })
          vim.notify("File saved (async, large file)", vim.log.levels.INFO)
        end
      end)
    end)
  end)
end

M.smart_save = function()
  if is_large_file() then
    M.async_save()
  else
    vim.b.skip_save_hooks = nil
    vim.cmd('silent w')
  end
end

return M