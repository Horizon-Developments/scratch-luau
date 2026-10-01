return function(R, V)
	R:defineCategory("Operators", { name = "Operators", color = { 89, 192, 89 } })

	local function binary(id, sym, shape, inType, fn, defaults)
		R:defineBlock({ id = id, category = "Operators", shape = shape,
			label = "{A} " .. sym .. " {B}",
			inputs = { A = { type = inType, default = defaults and defaults[1] }, B = { type = inType, default = defaults and defaults[2] } },
			run = function(_, a) return fn(a.A, a.B) end })
	end

	binary("op_add", "+", "reporter", "number", function(a, b) return a + b end)
	binary("op_sub", "-", "reporter", "number", function(a, b) return a - b end)
	binary("op_mul", "*", "reporter", "number", function(a, b) return a * b end)
	binary("op_div", "/", "reporter", "number", function(a, b) return a / b end) -- x/0 -> inf, like Luau
	binary("op_mod", "mod", "reporter", "number", function(a, b)
		if b == 0 then return 0 / 0 end -- NaN, like Luau
		local r = math.fmod(a, b)
		if r / b < 0 then r = r + b end -- floored, not truncated
		return r
	end)
	-- Luau comparison: == is strict (1 ~= "1", "a" ~= "A"), < and > take two numbers or two texts and error otherwise.
	binary("op_gt", ">", "boolean", "any", function(a, b) return V.less(b, a) end, { 0, 50 })
	binary("op_lt", "<", "boolean", "any", function(a, b) return V.less(a, b) end, { 0, 50 })
	binary("op_eq", "=", "boolean", "any", function(a, b) return V.equals(a, b) end, { 0, 50 })

	-- Luau and / or: short-circuit and return one of the operands (not just true / false). The slots stay hexagons but
	-- are raw + lazy: the right side is only evaluated when needed, and a value (variable, item of list) passes through.
	local function logic(id, sym, stopWhen)
		R:defineBlock({ id = id, category = "Operators", shape = "boolean", label = "{A} " .. sym .. " {B}",
			inputs = { A = { type = "boolean", raw = true, lazy = true }, B = { type = "boolean", raw = true, lazy = true } },
			run = function(ctx)
				local a = ctx:input("A")
				if V.toBool(a) == stopWhen then return a end
				return ctx:input("B")
			end })
	end
	logic("op_and", "and", false)
	logic("op_or", "or", true)

	R:defineBlock({ id = "op_not", category = "Operators", shape = "boolean", label = "not {A}",
		inputs = { A = { type = "boolean" } }, run = function(_, a) return not a.A end })

	-- Not in Scratch's core set: the value form of if/else, so a variable can be set to "this if that, else the other".
	-- Only the chosen branch is evaluated (lazy), like the if/else block.
	R:defineBlock({ id = "op_if_else", category = "Operators", shape = "reporter", label = "if {COND} then {A} else {B}",
		inputs = { COND = { type = "boolean", lazy = true }, A = { type = "any", default = 1, lazy = true }, B = { type = "any", default = 0, lazy = true } },
		run = function(ctx)
			if ctx:input("COND") then return ctx:input("A") end
			return ctx:input("B")
		end })

	-- math.random(m, n): whole numbers, m <= n (Luau errors on an empty interval).
	R:defineBlock({ id = "op_random", category = "Operators", shape = "reporter",
		label = "pick random {FROM} to {TO}",
		inputs = { FROM = { type = "number", default = 1 }, TO = { type = "number", default = 10 } },
		run = function(_, a)
			-- bounds are clamped to the int32 range so math.random never gets a value it cannot represent (Lua 5.4 and Luau)
			local LIM = 2147483647
			local function whole(x) x = math.max(-LIM, math.min(LIM, x)) return x >= 0 and math.floor(x) or -math.floor(-x) end
			local lo, hi = whole(a.FROM), whole(a.TO)
			if lo > hi then error("interval is empty", 0) end
			return math.random(lo, hi)
		end })

	-- Text for the string blocks: text as it is, numbers like string.len(5) / ("x"):rep, anything else is an error.
	local function str(v)
		if type(v) == "string" then return v end
		if type(v) == "number" then return V.toString(v) end
		error("expected text, got " .. V.typeName(v), 0)
	end

	-- Luau `..`: text or numbers only (nil and booleans are an error).
	R:defineBlock({ id = "op_join", category = "Operators", shape = "reporter", label = "join {A} {B}",
		inputs = { A = { type = "any", default = "apple ", raw = true }, B = { type = "any", default = "banana", raw = true } },
		run = function(_, a)
			if type(a.A) ~= "string" and type(a.A) ~= "number" then error("attempt to concatenate " .. V.typeName(a.A), 0) end
			if type(a.B) ~= "string" and type(a.B) ~= "number" then error("attempt to concatenate " .. V.typeName(a.B), 0) end
			local x, y = str(a.A), str(a.B)
			if #x + #y > V.LIMITS.MAX_STRING then error("string too long", 0) end
			return x .. y
		end })

	-- string.sub(s, n, n): bytes, negative n counts from the end, out of range is "".
	R:defineBlock({ id = "op_letter", category = "Operators", shape = "reporter", label = "letter {N} of {S}",
		inputs = { N = { type = "number", default = 1 }, S = { type = "any", default = "apple", raw = true } },
		run = function(_, a)
			local n = a.N >= 0 and math.floor(a.N) or -math.floor(-a.N)
			if n ~= n or n == math.huge or n == -math.huge then return "" end
			return string.sub(str(a.S), n, n)
		end })

	-- #s: length in bytes (a letter outside ASCII counts as 2 to 4).
	R:defineBlock({ id = "op_length", category = "Operators", shape = "reporter", label = "length of {S}",
		inputs = { S = { type = "any", default = "apple", raw = true } }, run = function(_, a) return #str(a.S) end })

	-- string.find(s, t, 1, true): case-sensitive.
	R:defineBlock({ id = "op_contains", category = "Operators", shape = "boolean", label = "{S} contains {T}",
		inputs = { S = { type = "any", default = "apple", raw = true }, T = { type = "any", default = "a", raw = true } },
		run = function(_, a) return string.find(str(a.S), str(a.T), 1, true) ~= nil end })

	-- tonumber(x): the number, or nil when x is not one. tostring(x): text, so "1" == tostring(1).
	R:defineBlock({ id = "op_tonumber", category = "Operators", shape = "reporter", output = "any", label = "tonumber {A}",
		inputs = { A = { type = "any", default = "10", raw = true } },
		run = function(_, a)
			if type(a.A) == "number" then return a.A end
			if type(a.A) == "string" then return V.parseNumber(a.A) end
			return nil
		end })
	R:defineBlock({ id = "op_tostring", category = "Operators", shape = "reporter", label = "tostring {A}",
		inputs = { A = { type = "any", default = 10, raw = true } },
		run = function(_, a) return V.toString(a.A) end })

	-- nil: the empty value. false and nil are the only falsy values.
	R:defineBlock({ id = "op_nil", category = "Operators", shape = "reporter", output = "any", label = "nil",
		run = function() return nil end })

	-- math.round: halves round away from zero.
	R:defineBlock({ id = "op_round", category = "Operators", shape = "reporter", label = "round {A}",
		inputs = { A = { type = "number" } }, run = function(_, a) return V.round(a.A) end })

	-- Luau math: angles are in radians. `pi` is math.pi.
	R:defineBlock({ id = "op_pi", category = "Operators", shape = "reporter", label = "pi", run = function() return math.pi end })

	local MATH = {
		abs = math.abs, floor = math.floor, ceiling = math.ceil, sqrt = math.sqrt,
		sin = math.sin, cos = math.cos, tan = math.tan,
		asin = math.asin, acos = math.acos, atan = math.atan,
		ln = math.log, log = function(x) return math.log(x) / math.log(10) end,
		["e ^"] = math.exp, ["10 ^"] = function(x) return 10 ^ x end,
	}
	R:defineBlock({ id = "op_math", category = "Operators", shape = "reporter", label = "{FN} of {A}",
		inputs = { FN = { type = "string", default = "abs", options = { "abs", "floor", "ceiling", "sqrt", "sin", "cos", "tan", "asin", "acos", "atan", "ln", "log", "e ^", "10 ^" } },
			A = { type = "number" } },
		run = function(_, a) local f = MATH[a.FN] return f and f(a.A) or 0 end })
end
