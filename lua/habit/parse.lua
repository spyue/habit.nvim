-- habit.nvim: parser for finding trackers and turning them into data
local config = require("habit.config")

local M = {}

-- Find all boxes on a line
-- Gives a list {{col = #, done = true}, {col = #, done = false}}
local function find_boxes(line)
	local o = config.options
	local kinds = {
		{ state = "empty", symbol = o.empty },
		{ state = "done", symbol = o.done },
		{ state = "omit", symbol = o.omit },
	}
	local boxes = {}
	local pos = 1

	while true do
		local start, found
		for _, kind in ipairs(kinds) do
			local s = line:find(kind.symbol, pos, true)
			if s and (not start or s < start) then
				start, found = s, kind
			end
		end
		if not start then
			break
		end

		table.insert(boxes, {
			col = start,
			len = #found.symbol,
			state = found.state,
			done = found.state == "done",
		})
		pos = start + #found.symbol
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

-- Turns date_format into a lua pattern
local function date_pattern(fmt)
	local order = {}
	local pat = fmt:gsub("[%^%$%(%)%.%[%]%*%+%-%?]", "%%%0")
	pat = pat:gsub("%%([Ymd])", function(k)
		table.insert(order, k)
		return k == "Y" and "(%d%d%d%d)" or "(%d%d)"
	end)
	return "^" .. pat, order
end

-- Read the date at the start of a header line and return timestamp
function M.date(text)
	local pat, order = date_pattern(config.options.date_format)
	local caps = { text:match(pat) }
	if #caps ~= 3 then
		return nil
	end

	local t = { hour = 12 }
	for i, k in ipairs(order) do
		local n = tonumber(caps[i])
		if k == "Y" then
			t.year = n
		elseif k == "m" then
			t.month = n
		else
			t.day = n
		end
	end
	return os.time(t)
end

-- Find every tracker in a list of lines:
-- a header line with a date followed by one or more tasks
function M.trackers(lines)
	local found = {}
	local i = 2

	while i <= #lines do
		local task = M.line(lines[i])
		local start = task and M.date(vim.trim(lines[i - 1]))

		if start then
			local tracker = { start = start, line = i - 1, tasks = {} }
			while task do
				table.insert(tracker.tasks, task)
				i = i + 1
				task = lines[i] and M.line(lines[i])
			end
			table.insert(found, tracker)
		else
			i = i + 1
		end
	end

	return found
end

return M
