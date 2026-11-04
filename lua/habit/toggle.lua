-- habit.nvim: flip the box under the cursor

local config = require("habit.config")
local parse = require("habit.parse")

local M = {}

function M.toggle()
	local o = config.options
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
		local old = box.done and o.done or o.empty
		local last = box.col + #old - 1

		if col >= box.col and col <= last then
			local new = box.done and o.empty or o.done
			local updated = line:sub(1, box.col - 1) .. new .. line:sub(last + 1)
			vim.api.nvim_buf_set_lines(0, row - 1, row, false, { updated })
			return
		end
	end
end

return M
