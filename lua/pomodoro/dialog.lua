local M = {}

-- Global side-effect: seeds Lua's shared RNG once at module load.
-- os.clock() adds sub-second jitter beyond os.time()'s 1s granularity.
math.randomseed(os.time() + os.clock() * 1000)

local _win = nil

--- 10 phrase pairs: { break_phrase, stop_phrase }
--- Dialog picks one pair at random on each open.
local PHRASE_PAIRS = {
	-- { "hydrate or perish",       "yeet the timer" },
	-- { "touch grass protocol",    "unplug the hamster" },
	-- { "activate couch mode",     "eject eject eject" },
	-- { "release the snacks",      "ctrl alt retreat" },
	-- { "summon the tea wizard",   "abort mission captain" },
	-- { "nap.exe --force",         "pull the ripcord" },
	-- { "deploy the blanket",      "sudo stop" },
	-- { "engage chill thrusters",  "defuse the tomato" },
	-- { "initiate vibe shift",     "rage quit gracefully" },
	-- { "begin snack acquisition", "the timer is a lie" },
	{ "mummi ko bolu kya?", "mummi aa gayi, band kar bsdk!" },
	{ "thoda paani pee le bhai", "sab moh maya hai" },
}

--- Check if the dialog is currently open.
---@return boolean
function M.is_open()
	return _win ~= nil and not _win.closed
end

--- Close the dialog.
function M.close()
	if _win and not _win.closed then
		_win:close()
	end
	_win = nil
end

--- Open the escalation dialog with a random phrase pair.
---@param opts { title: string, header_lines: string[] }
---@param on_dismiss fun(action: string) called with "break" or "stop"
function M.open(opts, on_dismiss)
	if M.is_open() then
		M.close()
	end

	-- Pick a random phrase pair
	local pair = PHRASE_PAIRS[math.random(#PHRASE_PAIRS)]
	local break_phrase = pair[1]
	local stop_phrase = pair[2]

	-- Build full display lines: header + blank + instructions
	local lines = {}
	for _, line in ipairs(opts.header_lines) do
		lines[#lines + 1] = line
	end
	lines[#lines + 1] = ""
	lines[#lines + 1] = "'" .. break_phrase .. "' → take a break"
	lines[#lines + 1] = "'" .. stop_phrase .. "' → stop the session"
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Type your choice below:"

	-- Create prompt buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buftype = "prompt"
	vim.bo[buf].bufhidden = "wipe"
	vim.fn.prompt_setprompt(buf, "▸ ")

	-- Pre-fill info lines above the prompt
	vim.api.nvim_buf_set_lines(buf, 0, 0, false, lines)

	-- Prevent E162 "No write since last change" by keeping buffer unmodified
	vim.api.nvim_create_autocmd("BufModifiedSet", {
		group = vim.api.nvim_create_augroup("PomodoroDialogModified_" .. buf, { clear = true }),
		buffer = buf,
		callback = function()
			if vim.api.nvim_buf_is_valid(buf) then
				vim.bo[buf].modified = false
			end
		end,
	})

	-- Set prompt callback for input validation
	vim.fn.prompt_setcallback(buf, function(input)
		local trimmed = vim.trim(input):lower()
		if trimmed == break_phrase then
			M.close()
			on_dismiss("break")
		elseif trimmed == stop_phrase then
			M.close()
			on_dismiss("stop")
		else
			vim.notify("Type one of: '" .. break_phrase .. "' / '" .. stop_phrase .. "'", vim.log.levels.WARN)
		end
	end)

	-- Block navigation/scroll/mouse in normal mode (not single-letter keys in insert — needed for typing)
	-- q is blocked to prevent Snacks.win default close behavior
	local block_n = {
		"q",
		"k",
		"j",
		"G",
		"<Up>",
		"<Down>",
		"gg",
		"<C-w>",
		"<C-u>",
		"<C-d>",
		"<C-f>",
		"<C-b>",
		"<ScrollWheelUp>",
		"<ScrollWheelDown>",
		"<LeftMouse>",
		"<RightMouse>",
	}
	local block_i = { "<Up>", "<Down>", "<C-w>", "<ScrollWheelUp>", "<ScrollWheelDown>", "<LeftMouse>", "<RightMouse>" }
	for _, key in ipairs(block_n) do
		vim.api.nvim_buf_set_keymap(buf, "n", key, "", { noremap = true, silent = true })
	end
	for _, key in ipairs(block_i) do
		vim.api.nvim_buf_set_keymap(buf, "i", key, "", { noremap = true, silent = true })
	end

	-- Open via Snacks.win — disable default q-to-close
	_win = Snacks.win({
		buf = buf,
		position = "float",
		width = 60,
		height = #lines + 4,
		border = "rounded",
		title = " " .. opts.title .. " ",
		title_pos = "center",
		enter = true,
		keys = { q = false },
		on_close = function()
			_win = nil
		end,
	})

	vim.cmd("startinsert")
end

return M
