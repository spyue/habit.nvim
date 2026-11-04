-- habit.nvim: tracker inserter
local config = require("habit.config")

local M = {}

function M.setup(opts)
	config.setup(opts)

	-- insert key
	local insert_key = config.options.keymaps.insert
	if insert_key then
		vim.keymap.set("n", insert_key, M.insert, { desc = "Insert habit tracker" })
	end
	-- toggle key
	local toggle_key = config.options.keymaps.toggle
	if toggle_key then
		vim.keymap.set("n", toggle_key, M.toggle, { desc = "Flip box the cursor is hovering" })
	end
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
	return os.date(config.options.date_format, now - (weekday - 1) * 86400)
end

function M.build()
	local c = config.options
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

function M.toggle()
	require("habit.toggle").toggle()
end

return M
