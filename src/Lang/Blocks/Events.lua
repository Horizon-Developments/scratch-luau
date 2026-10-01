return function(R, V)
	R:defineCategory("Events", { name = "Events", color = { 255, 191, 0 } })

	R:defineBlock({ id = "events_when_run", category = "Events", shape = "hat",
		label = "when {@flag} clicked", hat = { event = "run" } })

	R:defineBlock({ id = "events_when_broadcast", category = "Events", shape = "hat",
		label = "when I receive {MESSAGE}",
		inputs = { MESSAGE = { type = "string", default = "message1", reporters = false } },
		hat = { event = "broadcast", filter = function(args, payload) return V.equals(args.MESSAGE, payload) end } })

	-- Key names are Scratch's. A key press while the script is still running is ignored (once). The host fires interp:fire("key", name) on a key press; the run then stays alive until Stop.
	R:defineBlock({ id = "events_when_key", category = "Events", shape = "hat",
		label = "when {KEY} key pressed",
		inputs = { KEY = { type = "string", default = "space", options = V.KEYS, reporters = false } },
		hat = { event = "key", persistent = true, once = true, filter = function(args, payload) return args.KEY == "any" or args.KEY == payload end } })

	-- Edge-triggered: starts its script each time the timer rises past VALUE (checked every frame).
	R:defineBlock({ id = "events_when_timer", category = "Events", shape = "hat",
		label = "when timer > {VALUE}",
		inputs = { VALUE = { type = "number", default = 10 } },
		hat = { event = "edge", poll = function(args, interp) return interp:timer() > args.VALUE end } })

	R:defineBlock({ id = "events_broadcast", category = "Events", shape = "stack",
		label = "broadcast {MESSAGE}",
		inputs = { MESSAGE = { type = "string", default = "message1" } },
		run = function(ctx, args) ctx.interp:fire("broadcast", args.MESSAGE, ctx.thread) end })

	R:defineBlock({ id = "events_broadcast_wait", category = "Events", shape = "stack",
		label = "broadcast {MESSAGE} and wait",
		inputs = { MESSAGE = { type = "string", default = "message1" } },
		run = function(ctx, args)
			local threads = ctx.interp:fire("broadcast", args.MESSAGE, ctx.thread)
			local function pending()
				for _, t in ipairs(threads) do if not t.done then return true end end
				return false
			end
			while ctx:alive() and pending() do ctx:yield() end
		end })
end
