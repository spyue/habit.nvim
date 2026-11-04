-- habit.nvim: parser for finding trackers and turning them into data
local config = require("habit.config")

local M = {}

-- Find all boxes on a line
-- Gives a list {{col = #, done = true}, {col = #, done = false}}
local function find_boxes(line)
	local o = config.options
	local boxes = {}
	local pos = 1

	while true do
		local e = line:find(o.empty, pos, true)
		local d = line:find(o.done, pos, true)

		local start, done
		if e and (not d or e < d) then
			start, done = e, false
		elseif d then
			start, done = d, true
		else
			break
		end

		table.insert(boxes, { col = start, done = done })
		pos = start + #(done and o.done or o.empty)
	end
	return boxes
end

-- Parse one task row
-- Return { name = ..., boxes = {...} }, or nil if row is not a
-- proper tracker row (wrong amount of boxes, etc...)
function M.line(line)
	local boxes = find_boxes(line)
	if #boxes ~= #config.options.days then
		return nil
	end

	local name = vim.trim(line:sub(1, boxes[1].col - 1))
	if name == "" then
		return nil
	end

	return { name = name, boxes = boxes }
end

return M
