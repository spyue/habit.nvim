-- habit.nvim: floating stats window
local scan = require("habit.scan")
local stats = require("habit.stats")

local M = { win = nil, buf = nil }
local ns = vim.api.nvim_create_namespace("habit")

-- Builds the window's text from trackers
local function content()
	local trackers = scan.trackers()
	local rows = stats.summary(stats.collect(trackers))

	local name_w = 5
	for _, r in ipairs(rows) do
		name_w = math.max(name_w, vim.fn.strdisplaywidth(r.name))
	end
	local fmt = "  %-" .. name_w .. "s  %7s  %5s  %7s  %7s  "

	local lines = {
		"",
		string.format(fmt, "habit", "done", "rate", "current", "longest"),
		"  " .. string.rep("─", name_w + 34),
	}
	for _, r in ipairs(rows) do
		table.insert(lines, string.format(fmt, r.name, r.done .. "/" .. r.tracked, r.rate .. "%", r.current, r.longest))
	end
	if #rows == 0 then
		table.insert(lines, "  No trackers found under " .. vim.fn.getcwd() .. "  ")
	end
	table.insert(lines, "")
	table.insert(lines, string.format("  %d tracker(s)  ·  q close  ·  r refresh  ", #trackers))

	return lines
end

-- Put the text in the window and color the header, divider and footer
local function render(lines)
	vim.bo[M.buf].modifiable = true
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, lines)
	vim.bo[M.buf].modifiable = false

	vim.api.nvim_buf_clear_namespace(M.buf, ns, 0, -1)
	local function hl(row, group)
		vim.api.nvim_buf_set_extmark(M.buf, ns, row, 0, { end_col = #lines[row + 1], hl_group = group })
	end
	hl(1, "Title")
	hl(2, "Comment")
	hl(#lines - 1, "Comment")
end

-- Window size and position: fit the text, centered on screen
local function layout(lines)
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.fn.strdisplaywidth(l))
	end
	width = math.min(width, math.floor(vim.o.columns * 0.8))
	local height = math.min(#lines, math.floor(vim.o.lines * 0.8))

	return {
		relative = "editor",
		width = width,
		height = height,
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		style = "minimal",
		border = "rounded",
		title = " Habit Stats ",
		title_pos = "center",
	}
end

function M.close()
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_win_close(M.win, true)
	end
	M.win, M.buf = nil, nil
end

function M.refresh()
	if not (M.win and vim.api.nvim_win_is_valid(M.win)) then
		return
	end
	local lines = content()
	render(lines)
	vim.api.nvim_win_set_config(M.win, layout(lines))
end

function M.open()
	-- Already open? Just jump to it.
	if M.win and vim.api.nvim_win_is_valid(M.win) then
		vim.api.nvim_set_current_win(M.win)
		return
	end

	local lines = content()
	M.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[M.buf].bufhidden = "wipe"
	M.win = vim.api.nvim_open_win(M.buf, true, layout(lines))
	render(lines)

	local opts = { buffer = M.buf, nowait = true, silent = true }
	vim.keymap.set("n", "q", M.close, opts)
	vim.keymap.set("n", "<Esc>", M.close, opts)
	vim.keymap.set("n", "r", M.refresh, opts)

	-- Close it if you click or move to another window
	vim.api.nvim_create_autocmd("WinLeave", { buffer = M.buf, once = true, callback = M.close })
end

return M
