local M = {}

local function state_path()
	return vim.fn.stdpath("state") .. "/pomodoro.json"
end

--- Return the full path to the state file (for debugging).
function M.path()
	return state_path()
end

--- Read and parse the state file.
---@return table|nil state, or nil if file is missing or unreadable
function M.read()
	local path = state_path()
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or not lines or #lines == 0 then
		return nil
	end
	local json = table.concat(lines, "\n")
	local ok2, state = pcall(vim.json.decode, json)
	if not ok2 or type(state) ~= "table" then
		return nil
	end
	return state
end

--- Atomically write state to the file (tmp + rename).
---@param state table
function M.write(state)
	local path = state_path()
	local dir = vim.fn.fnamemodify(path, ":h")
	local ok_mkdir = pcall(vim.fn.mkdir, dir, "p")
	if not ok_mkdir then
		vim.notify("Pomodoro: could not create state dir — " .. dir, vim.log.levels.ERROR)
		return
	end
	local json = vim.json.encode(state)
	local tmp = path .. ".tmp"
	local result = vim.fn.writefile({ json }, tmp)
	if result ~= 0 then
		vim.notify("Pomodoro: state write failed — could not write tmp file", vim.log.levels.ERROR)
		return
	end
	local ok, err = os.rename(tmp, path)
	if not ok then
		vim.notify("Pomodoro: state write failed — " .. tostring(err), vim.log.levels.ERROR)
	end
end

--- Delete the state file. Idempotent.
function M.clear()
	pcall(vim.fn.delete, state_path())
end

return M
