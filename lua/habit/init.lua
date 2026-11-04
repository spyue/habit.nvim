-- Weekly habit tracker for nvim
local M = {}

M.config = {
	-- this is where you change your tasks
	tasks = { "task a", "task b", "task c" },

	-- this is where you can change the days layout
	days = { "M", "T", "W", "T", "F", "S", "S" },
	empty = "[ ]",
	done = "[X]",

	--can change date fromat here
	date_format = "%d-%m-%Y",
	gap = 2,
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

local function width(s)
	return vim.fn.strdisplaywidth(s)
end

local function pad(s, w)
	return s .. string.rep(" ", w - width(s))
end

local function center(s, w)
	local left = math.floor((w - width(s)) / 2)
	return pad(string.rep(" ", left) .. s, w)
end

local function week_start()
	local now = os.time()
	local weekday = tonumber(os.date("%u", now))
	return os.date(M.config.date_format, now - (weekday - 1) * 86400)
end

function M.build()
	local c = M.config
	local date = week_start()

	local first = width(date)
	for _, task in ipairs(c.tasks) do
		first = math.max(first, width(task))
	end

	local cell = math.max(width(c.empty), width(c.done))
	local sep = string.rep(" ", c.gap)

	local lines = {}

	local header = { pad(date, first) }
	for _, day in ipairs(c.days) do
		table.insert(header, center(day, cell))
	end
	table.insert(lines, (table.concat(header, sep):gsub("%s+$", "")))

	for _, task in ipairs(c.tasks) do
		local row = { pad(task, first) }
		for _ = 1, #c.days do
			table.insert(row, c.empty)
		end
		table.insert(lines, table.concat(row, sep))
	end
	return lines
end

function M.insert()
	local row = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, row, row, false, M.build())
end

return M
