-- Run external commands without blocking Hammerspoon's Lua event loop.
local M = {}
local activeTasks = {}

function M.run(path, arguments, timeoutSeconds, callback)
	local task
	local timer
	local finished = false
	local timeout = timeoutSeconds or 5

	local function finish(code, stdout, stderr)
		if finished then return end
		finished = true
		if timer then timer:stop(); timer = nil end
		if task then activeTasks[task] = nil end
		if callback then callback(code, stdout or "", stderr or "") end
	end

	local ok, createdTask = pcall(hs.task.new, path, finish, arguments or {})
	if not ok or not createdTask then
		finish(127, "", "could not create task for " .. path)
		return nil
	end
	task = createdTask
	activeTasks[task] = true

	timer = hs.timer.doAfter(timeout, function()
		if finished then return end
		if task and task:isRunning() then task:terminate() end
		finish(124, "", "timed out after " .. tostring(timeout) .. " seconds")
	end)

	local startOk, started = pcall(task.start, task)
	if not startOk or not started then
		finish(127, "", "could not start task for " .. path)
		return nil
	end
	return task
end

function M.sequence(path, commands, timeoutSeconds, callback)
	local results = {}
	local index = 1

	local function nextCommand()
		if index > #commands then
			if callback then callback(true, results) end
			return
		end

		local current = index
		M.run(path, commands[current], timeoutSeconds, function(code, stdout, stderr)
			results[current] = { code = code, stdout = stdout, stderr = stderr }
			if code ~= 0 then
				if callback then callback(false, results, current) end
				return
			end
			index = current + 1
			nextCommand()
		end)
	end

	nextCommand()
end

return M
