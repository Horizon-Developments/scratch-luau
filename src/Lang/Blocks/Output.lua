return function(R, V)
	R:defineCategory("Output", { name = "Output", color = { 15, 189, 140 } })

	R:defineBlock({ id = "out_print", category = "Output", shape = "stack", label = "print {TEXT}",
		inputs = { TEXT = { type = "string", default = "Hello!" } },
		run = function(ctx, a) ctx:say(a.TEXT, "say") end })

	R:defineBlock({ id = "out_clear", category = "Output", shape = "stack", label = "clear output",
		run = function(ctx) if ctx.interp.opts.clear then ctx.interp.opts.clear() end end })
end
