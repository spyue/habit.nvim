-- habit.nvim: streaks and habit stats
local M = {}

local DAY = 86400

-- A date as "YYYY-MM-DD" as a key for each day
local function key(t)
	return os.date("%Y-%m-%d", t)
end

-- Today at midday
local function today()
	local d = os.date("*t")
	return os.time({ year = d.year, month = d.month, day = d.day, hour = 12 })
end

-- Combine all trackers into one per task:
-- days["exercise"]["2026-11-02"] = true or false (done or not done)
local rank = { empty = 1, omit = 2, done = 3 }

function M.collect(trackers)
	local days = {}
	for _, tracker in ipairs(trackers) do
		for _, task in ipairs(tracker.tasks) do
			days[task.name] = days[task.name] or {}
			for i, box in ipairs(task.boxes) do
				local d = key(tracker.start + (i - 1) * DAY)

				local old = days[task.name][d]
				if not old or rank[box.state] > rank[old] then
					days[task.name][d] = box.state
				end
			end
		end
	end
	return days
end

-- Stats for one task's record
local function task_stats(record, now)
	local today = key(now)

	-- Done and rate count only days up to today, and leave omitted days out
	local done, tracked = 0, 0
	local first
	for k, state in pairs(record) do
		if k <= today then
			if state ~= "omit" then
				tracked = tracked + 1
				if state == "done" then
					done = done + 1
				end
			end
			if not first or k < first then
				first = k
			end
		end
	end
	if not first then
		return { done = 0, tracked = 0, rate = 0, current = 0, longest = 0 }
	end

	-- Current streak: count back from today. Omitted days are skipped over
	-- (they don't break the streak or add to it). If today isn't marked yet,
	-- start from yesterday, so an unfinished day doesn't break the streak.
	local t = now
	local s = record[key(t)]
	if s ~= "done" and s ~= "omit" then
		t = t - DAY
	end
	local current = 0
	while true do
		s = record[key(t)]
		if s == "done" then
			current = current + 1
		elseif s ~= "omit" then
			break
		end
		t = t - DAY
	end

	-- Longest streak: walk every day from the first tracked day to today
	local y, m, d = first:match("(%d+)-(%d+)-(%d+)")
	t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
	local longest, run = 0, 0
	while t <= now do
		s = record[key(t)]
		if s == "done" then
			run = run + 1
			longest = math.max(longest, run)
		elseif s ~= "omit" then
			run = 0
		end
		t = t + DAY
	end

	return {
		done = done,
		tracked = tracked,
		rate = tracked > 0 and math.floor(done / tracked * 100 + 0.5) or 0,
		current = current,
		longest = longest,
	}
end

-- Stats for every task by name
function M.summary(days)
	local now = today()
	local names = {}
	for name in pairs(days) do
		table.insert(names, name)
	end
	table.sort(names)

	local result = {}
	for _, name in ipairs(names) do
		local s = task_stats(days[name], now)
		s.name = name
		table.insert(result, s)
	end
	return result
end

return M
