-- ============================================================================
-- Pomodoro Timer - lazy.nvim spec
-- API lives at lua/pomodoro/init.lua (require("pomodoro"))
-- ============================================================================

return {
	dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h:h"),
	name = "pomodoro",
	event = "VeryLazy",
	keys = {
		{
			"<leader>ps",
			function()
				require("pomodoro").start()
			end,
			desc = "Start Pomodoro",
		},
		{
			"<leader>pp",
			function()
				require("pomodoro").toggle_pause()
			end,
			desc = "Pause/Resume Pomodoro",
		},
		{
			"<leader>px",
			function()
				require("pomodoro").stop()
			end,
			desc = "Stop Pomodoro",
		},
	},
	config = function()
		require("pomodoro") -- starts poll loop; picks up any running session from state file
	end,
}
