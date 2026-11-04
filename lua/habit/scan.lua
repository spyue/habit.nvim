-- habit.nvim: find trackers in markdown files in subfolders of the current folder
local parse = require("habit.parse")

local M = {}

-- All .md files under a folder (default is the current folder)
function M.files(dir)
	return vim.fs.find(function(name)
		return name:match("%.md$") ~= nil
	end, { path = dir or vim.fn.getcwd(), type = "file", limit = math.huge })
end

-- Every tracker in those files, each with a tag of where it came from
function M.trackers(dir)
	local all = {}
	for _, path in ipairs(M.files(dir)) do
		local ok, lines = pcall(vim.fn.readfile, path)
		if ok then
			for _, tracker in ipairs(parse.trackers(lines)) do
				tracker.file = path
				table.insert(all, tracker)
			end
		end
	end
	return all
end

return M
