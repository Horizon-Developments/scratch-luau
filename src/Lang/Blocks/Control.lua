return function(R, V)
	R:defineCategory("Control", { name = "Control", color = { 255, 171, 25 } })

	R:defineBlock({ id = "control_wait", category = "Control", shape = "stack",
		label = "wait {SECS} seconds",
		inputs = { SECS = { type = "number", default = 1 } },
		run = function(ctx, args) ctx:wait(math.max(0, args.SECS)) end })

	R:defineBlock({ id = "control_repeat", footerIcon = "loop", category = "Control", shape = "c",
		label = "repeat {TIMES}", stacks = { "SUBSTACK" },
		inputs = { TIMES = { type = "number", default = 10 } },
		run = function(ctx, args)
			for _ = 1, math.floor(args.TIMES) do -- like `for _ = 1, n`: 2.5 runs twice
				if not ctx:alive() then return "STOP" end
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
			end
		end })

	-- An end block like Scratch's: nothing can attach below it (a dropped stack wraps inside it instead).
	R:defineBlock({ id = "control_forever", footerIcon = "loop", category = "Control", shape = "cap",
		label = "forever", stacks = { "SUBSTACK" },
		run = function(ctx)
			while ctx:alive() do
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
			end
			return "STOP"
		end })

	R:defineBlock({ id = "control_if", category = "Control", shape = "c",
		label = "if {COND} then", stacks = { "THEN" },
		inputs = { COND = { type = "boolean" } },
		run = function(ctx, args)
			if args.COND then return ctx:stack("THEN") end
		end })

	R:defineBlock({ id = "control_if_else", category = "Control", shape = "c",
		label = "if {COND} then", stacks = { "THEN", "ELSE" },
		inputs = { COND = { type = "boolean" } },
		run = function(ctx, args)
			return ctx:stack(args.COND and "THEN" or "ELSE")
		end })

	R:defineBlock({ id = "control_wait_until", category = "Control", shape = "stack",
		label = "wait until {COND}",
		inputs = { COND = { type = "boolean", lazy = true } },
		run = function(ctx)
			while ctx:alive() and not ctx:input("COND") do ctx:yield() end
		end })

	R:defineBlock({ id = "control_repeat_until", footerIcon = "loop", category = "Control", shape = "c",
		label = "repeat until {COND}", stacks = { "SUBSTACK" },
		inputs = { COND = { type = "boolean", lazy = true } },
		run = function(ctx)
			while ctx:alive() and not ctx:input("COND") do
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
			end
		end })

	R:defineBlock({ id = "control_while", footerIcon = "loop", category = "Control", shape = "c",
		label = "while {COND}", stacks = { "SUBSTACK" },
		inputs = { COND = { type = "boolean", lazy = true } },
		run = function(ctx)
			while ctx:alive() and ctx:input("COND") do
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
			end
		end })

	-- Luau numeric for: `for VAR = 1, VALUE do`. VALUE is read once, before the first pass (2.5 gives 1, 2).
	R:defineBlock({ id = "control_for_each", footerIcon = "loop", category = "Control", shape = "c",
		label = "for {VAR} = 1 to {VALUE}", stacks = { "SUBSTACK" },
		inputs = { VAR = { type = "variable", default = "i" }, VALUE = { type = "number", default = 10 } },
		run = function(ctx, a)
			local i = 1
			while ctx:alive() and i <= a.VALUE do
				ctx.interp:setVar(a.VAR, i)
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
				i = i + 1
			end
		end })

	-- Luau `for _, VAR in ipairs(LIST) do`: the list is bound once; items added during the loop are still visited.
	R:defineBlock({ id = "control_for_in", footerIcon = "loop", category = "Control", shape = "c",
		label = "for each {VAR} in {LIST}", stacks = { "SUBSTACK" },
		inputs = { VAR = { type = "variable", default = "item" }, LIST = { type = "list", default = "my list" } },
		run = function(ctx, a)
			local l = ctx.interp:list(a.LIST)
			local i = 1
			while ctx:alive() and l[i] ~= nil do
				ctx.interp:setVar(a.VAR, l[i])
				local sig = ctx:stack("SUBSTACK")
				if sig then return sig end
				ctx:loopStep()
				i = i + 1
			end
		end })

	-- Scratch's own block only runs its contents (it is deprecated there); it does not change scheduling.
	R:defineBlock({ id = "control_all_at_once", category = "Control", shape = "c",
		label = "all at once", stacks = { "SUBSTACK" },
		run = function(ctx) return ctx:stack("SUBSTACK") end })

	R:defineBlock({ id = "control_get_counter", category = "Control", shape = "reporter", label = "counter",
		run = function(ctx) return ctx.interp.counter end })
	R:defineBlock({ id = "control_incr_counter", category = "Control", shape = "stack", label = "increment counter",
		run = function(ctx) ctx.interp.counter = ctx.interp.counter + 1 end })
	R:defineBlock({ id = "control_clear_counter", category = "Control", shape = "stack", label = "clear counter",
		run = function(ctx) ctx.interp.counter = 0 end })

	-- "other scripts" is a stack block (things can follow it); "this script" and "all" end the script (cap).
	R:defineBlock({ id = "control_stop", category = "Control", shape = "cap",
		label = "stop {OPTION}",
		inputs = { OPTION = { type = "string", default = "this script", options = { "this script", "all", "other scripts" } } },
		shapeOf = function(block) return block.inputs.OPTION == "other scripts" and "stack" or "cap" end,
		run = function(ctx, args)
			if args.OPTION == "all" then ctx:stopAll() return "STOP" end
			if args.OPTION == "other scripts" then ctx:stopOthers() return nil end
			return "STOP"
		end })

	-- error(message): ends the script with an error naming this block. A cap: nothing can follow it.
	R:defineBlock({ id = "control_error", category = "Control", shape = "cap", label = "error {MESSAGE}",
		inputs = { MESSAGE = { type = "any", default = "something went wrong", raw = true } },
		run = function(_, a) error(V.toString(a.MESSAGE), 0) end })

	-- pcall: runs TRY; if a block in it errors, the message goes into VAR and CATCH runs. Thread bookkeeping that an
	-- error unwinds past (nesting depth, My Block frames, warp) is put back so the script carries on cleanly.
	R:defineBlock({ id = "control_pcall", category = "Control", shape = "c",
		label = "pcall, error message in {VAR}", stacks = { "TRY", "CATCH" },
		inputs = { VAR = { type = "variable", default = "err" } },
		run = function(ctx, a)
			local t = ctx.thread
			local cur, depth, calls, frame, warp = t.cur, t.execDepth, t.depth, t.frame, t.warp
			local ok, res = pcall(ctx.stack, ctx, "TRY")
			if ok then return res end
			t.cur, t.execDepth, t.depth, t.frame, t.warp = cur, depth, calls, frame, warp
			ctx.interp:setVar(a.VAR, V.toString(res))
			return ctx:stack("CATCH")
		end })
end
