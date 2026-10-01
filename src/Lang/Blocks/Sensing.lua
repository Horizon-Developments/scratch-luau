return function(R, V)
	R:defineCategory("Sensing", { name = "Sensing", color = { 92, 177, 214 } })

	R:defineBlock({ id = "sensing_ask", category = "Sensing", shape = "stack", label = "ask {PROMPT} and wait",
		inputs = { PROMPT = { type = "string", default = "What's your name?" } },
		run = function(ctx, a)
			local ask = ctx.interp.opts.ask -- host supplies a yielding prompt function
			local thread = ctx.thread
			thread.asking = true -- stop() leaves a thread inside ask() alone; the prompt resumes it and it unwinds
			local ok, reply = pcall(function() return ask and V.toString(ask(a.PROMPT)) or "" end)
			thread.asking = false
			if not ok then error(reply, 0) end
			ctx.interp.answer = string.sub(reply, 1, V.LIMITS.MAX_STRING)
		end })

	R:defineBlock({ id = "sensing_answer", category = "Sensing", shape = "reporter", label = "answer",
		run = function(ctx) return ctx.interp.answer end })

	-- Key and mouse state come from the host (opts.keyDown / opts.mouseDown); without them these read false.
	-- The key menu accepts a reporter in Scratch, so reporters = true.
	R:defineBlock({ id = "sensing_keypressed", category = "Sensing", shape = "boolean", label = "key {KEY} pressed?",
		inputs = { KEY = { type = "string", default = "space", options = V.KEYS, reporters = true } },
		run = function(ctx, a) return ctx.interp:keyDown(a.KEY) end })

	R:defineBlock({ id = "sensing_mousedown", category = "Sensing", shape = "boolean", label = "mouse down?",
		run = function(ctx) return ctx.interp:mouseDown() end })

	local UNITS = { "year", "month", "date", "day of week", "hour", "minute", "second" }
	R:defineBlock({ id = "sensing_current", category = "Sensing", shape = "reporter", label = "current {UNIT}",
		inputs = { UNIT = { type = "string", default = "year", options = UNITS } },
		run = function(ctx, a)
			local d = ctx.interp:localDate()
			local map = { year = d.year, month = d.month, date = d.day, ["day of week"] = d.wday,
				hour = d.hour, minute = d.min, second = d.sec }
			return map[a.UNIT] or 0
		end })

	R:defineBlock({ id = "sensing_dayssince2000", category = "Sensing", shape = "reporter", label = "days since 2000",
		run = function(ctx) return ctx.interp:daysSince2000() end })

	R:defineBlock({ id = "sensing_timer", category = "Sensing", shape = "reporter", label = "timer",
		run = function(ctx) return ctx.interp:timer() end })

	R:defineBlock({ id = "sensing_reset_timer", category = "Sensing", shape = "stack", label = "reset timer",
		run = function(ctx) ctx.interp:resetTimer() end })
end
