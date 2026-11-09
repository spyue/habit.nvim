-- habit.nvim: flip the box under the cursor

local config = require("habit.config")
local parse = require("habit.parse")

local M = {}

function M.mark(target)
	local o = config.options
	local symbols = { empty = o.empty, done = o.done, omit = o.omit }

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local col = cursor[2] + 1
	local line = vim.api.nvim_get_current_line()

	local task = parse.line(line)
	if not task then
		vim.notify("habit.nvim: not a task row", vim.log.levels.INFO)
		return
	end

	for _, box in ipairs(task.boxes) do
		local last = box.col + box.len - 1

		if col >= box.col and col <= last then
			local new = box.state == target and "empty" or target
			local updated = line:sub(1, box.col - 1) .. symbols[new] .. line:sub(last + 1)
			vim.api.nvim_buf_set_lines(0, row - 1, row, false, { updated })
			return
		end
	end

	vim.notify("habit.nvim: put cursor on box", vim.log.levels.INFO)
end

function M.toggle()
	M.mark("done")
end

function M.omit()
	M.mark("omit")
end

return M
