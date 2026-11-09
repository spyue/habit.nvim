-- habit.nvim: shared config
local M = {}

M.defaults = {
	-- this is default, change your tasks in habit.lua in your dotfiles
	tasks = { "task a", "task b", "task c" },

	-- this is where you can change the days layout
	days = { "M", "T", "W", "T", "F", "S", "S" },
	empty = "[ ]",
	done = "[X]",
	omit = "[O]",

	--can change date fromat here
	date_format = "%Y-%m-%d",
	gap = 2,

	keymaps = {
		insert = "<localleader>hi",
		toggle = "<localleader>hd",
		stats = "<localleader>hs",
		omit = "<localleader>ho",
	},
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
