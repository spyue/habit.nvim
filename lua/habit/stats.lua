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
function M.collect(trackers)
	local days = {}
	for _, tracker in ipairs(trackers) do
		for _, task in ipairs(tracker.tasks) do
			days[task.name] = days[task.name] or {}
			for i, box in ipairs(task.boxes) do
				local d = key(tracker.start + (i - 1) * DAY)
				days[task.name][d] = days[task.name][d] or box.done
			end
		end
	end
	return days
end

-- Stats for one task's record
local function task_stats(record, now)
	local done, tracked = 0, 0
	local first
	for k, v in pairs(record) do
		if k <= key(now) then
			tracked = tracked + 1
			if v then
				done = done + 1
			end
			if not first or k < first then
				first = k
			end
		end
	end
	if not first then
		return { done = 0, tracked = 0, rate = 0, current = 0, longest = 0 }
	end

	local t = now
	if not record[key(t)] then
		t = t - DAY
	end
	local current = 0
	while record[key(t)] do
		current = current + 1
		t = t - DAY
	end

	local y, m, d = first:match("(%d+)-(%d+)-(%d+)")
	t = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d), hour = 12 })
	local longest, run = 0, 0
	while t <= now do
		if record[key(t)] then
			run = run + 1
			longest = math.max(longest, run)
		else
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
