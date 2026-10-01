return function(R, V)
	R:defineCategory("Variables", { name = "Variables", color = { 255, 140, 26 } })

	R:defineBlock({ id = "data_set", category = "Variables", shape = "stack", label = "set {NAME} to {VALUE}",
		inputs = { NAME = { type = "variable", default = "my variable" }, VALUE = { type = "any", default = 0 } },
		run = function(ctx, a) ctx.interp:setVar(a.NAME, a.VALUE) end })

	R:defineBlock({ id = "data_change", category = "Variables", shape = "stack", label = "change {NAME} by {BY}",
		inputs = { NAME = { type = "variable", default = "my variable" }, BY = { type = "number", default = 1 } },
		run = function(ctx, a) ctx.interp:setVar(a.NAME, V.toNumber(ctx.interp.vars[a.NAME]) + a.BY) end })

	R:defineBlock({ id = "data_get", category = "Variables", shape = "reporter", output = "any", label = "{NAME}",
		inputs = { NAME = { type = "variable", default = "my variable" } },
		-- a variable nobody set is nil (falsy), like an unset Luau variable
		run = function(ctx, a) return ctx.interp.vars[a.NAME] end })
end
