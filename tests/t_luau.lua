-- Blocks follow Luau, not Scratch: strict ==, truthiness, and/or values, tonumber/tostring, errors, pcall, lists.
package.path = "tests/?.lua;" .. package.path
LISTDIR = LISTDIR or function(d) local p = io.popen("ls " .. d); local s = p:read("a"); p:close(); return s end
local H = require("harness")
local b, script, prog = H.b, H.script, H.prog
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end
-- runs [print blk] and returns the printed text (or "ERR: msg")
local function eval(blk, pre)
	local T = H.new()
	local blocks = { b("events_when_run") }
	for _, x in ipairs(pre or {}) do blocks[#blocks + 1] = x end
	blocks[#blocks + 1] = b("out_print", { TEXT = blk })
	T.interp:run(prog(script(table.unpack(blocks))))
	T.S.run(60, function() return not T.interp.running end)
	if T.errs[1] then return "ERR: " .. tostring(T.errs[1][1]) end
	return table.concat(T.out, "|")
end
local function iff(c) return b("op_if_else", { COND = c, A = "yes", B = "no" }) end
local function get(n) return b("data_get", { NAME = n }) end
local function set(n, v) return b("data_set", { NAME = n, VALUE = v }) end

-- truthiness
eq("if 0", eval(iff(get("z")), { set("z", 0) }), "yes")
eq("if empty text", eval(iff(get("z")), { set("z", "") }), "yes")
eq("if unset var (nil)", eval(iff(get("never"))), "no")
eq("if nil block", eval(iff(b("op_nil"))), "no")
eq("if false", eval(iff(b("op_not", { A = b("op_nil") }))), "yes")
-- strict ==
eq("1 = '1'", eval(iff(b("op_eq", { A = 1, B = b("op_tostring", { A = 1 }) }))), "no")
eq("tonumber('1') = 1", eval(iff(b("op_eq", { A = b("op_tonumber", { A = b("op_tostring", { A = 1 }) }), B = 1 }))), "yes")
eq("'a' = 'A'", eval(iff(b("op_eq", { A = "a", B = "A" }))), "no")
eq("tonumber('abc') = nil", eval(iff(b("op_eq", { A = b("op_tonumber", { A = "abc" }), B = b("op_nil") }))), "yes")
eq("tostring(0.1+0.2)", eval(b("op_tostring", { A = b("op_add", { A = 0.1, B = 0.2 }) })), "0.3")
-- compare errors
eq("1 < text", (eval(b("op_lt", { A = 1, B = "x" })):gsub("^(ERR: attempt to compare number with string).*", "%1")), "ERR: attempt to compare number with string")
eq("text < text", eval(iff(b("op_lt", { A = "a", B = "b" }))), "yes")
-- and / or: values and short circuit
eq("'x' and 'y'", eval(b("op_and", { A = "x", B = "y" })), "y")
eq("nil or 'y'", eval(b("op_or", { A = b("op_nil"), B = "y" })), "y")
eq("0 or 'y' (0 is truthy)", eval(b("op_or", { A = 0, B = "y" })), "0")
eq("and short-circuits", eval(b("op_and", { A = b("op_nil"), B = b("op_lt", { A = 1, B = "x" }) })), "nil")
eq("or short-circuits", eval(b("op_or", { A = "ok", B = b("op_lt", { A = 1, B = "x" }) })), "ok")
-- arithmetic coercion
eq("'abc' + 1 errors", (eval(b("op_add", { A = "abc", B = 1 })):sub(1, 25)), "ERR: expected a number, g")
eq("'5' + 1", eval(b("op_add", { A = "5", B = 1 })), "6")
eq("nil + 1 errors", (eval(b("op_add", { A = b("op_nil"), B = 1 })):sub(1, 25)), "ERR: expected a number, g")
eq("change unset var errors", (eval(get("q"), { b("data_change", { NAME = "q", BY = 1 }) }):sub(1, 25)), "ERR: expected a number, g")
-- math
eq("round -2.5", eval(b("op_round", { A = -2.5 })), "-3")
eq("sin(pi/2) radians", eval(b("op_math", { FN = "sin", A = b("op_div", { A = b("op_pi"), B = 2 }) })), "1")
eq("random empty interval", eval(b("op_random", { FROM = 5, TO = 1 })), "ERR: interval is empty")
-- strings
eq("length bytes", eval(b("op_length", { S = "h\u{e9}llo" })), "6")
eq("letter 1", eval(b("op_letter", { N = 1, S = "apple" })), "a")
eq("letter -1", eval(b("op_letter", { N = -1, S = "apple" })), "e")
eq("letter out of range", eval(b("op_letter", { N = 9, S = "apple" })), "")
eq("contains is case sensitive", eval(iff(b("op_contains", { S = "Apple", T = "a" }))), "no")
eq("join text + number", eval(b("op_join", { A = "n=", B = 5 })), "n=5")
eq("join nil errors", (eval(b("op_join", { A = "n=", B = b("op_nil") })):sub(1, 33)), "ERR: attempt to concatenate nil")
-- lists
eq("item out of range is nil", eval(b("list_item", { INDEX = 3, LIST = "L" })), "nil")
eq("item # missing is nil", eval(b("list_indexof", { ITEM = "x", LIST = "L" })), "nil")
eq("item 1.5 is nil", eval(b("list_item", { INDEX = 1.5, LIST = "L" }), { b("list_add", { ITEM = "a", LIST = "L" }) }), "nil")
-- for each item in list
do
	local T = H.new()
	local a = script(b("events_when_run"), b("list_add", { ITEM = "a", LIST = "L" }), b("list_add", { ITEM = "b", LIST = "L" }),
		b("control_for_in", { VAR = "it", LIST = "L" }, { SUBSTACK = { b("out_print", { TEXT = get("it") }) } }))
	T.interp:run(prog(a)); T.S.run(30, function() return not T.interp.running end)
	eq("for each item in list", table.concat(T.out, ","), "a,b")
end
-- repeat floors
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_repeat", { TIMES = 2.5 }, { SUBSTACK = { b("out_print", { TEXT = "x" }) } }))
	T.interp:run(prog(a)); T.S.run(30, function() return not T.interp.running end)
	eq("repeat 2.5 runs twice", #T.out, 2)
end
-- error + pcall
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_pcall", { VAR = "err" }, {
		TRY = { b("out_print", { TEXT = "before" }), b("control_error", { MESSAGE = "boom" }), },
		CATCH = { b("out_print", { TEXT = get("err") }) } }), b("out_print", { TEXT = "after" }))
	T.interp:run(prog(a)); T.S.run(30, function() return not T.interp.running end)
	eq("pcall catches error() and carries on", table.concat(T.out, ","), "before,boom,after")
	eq("pcall: no error reported", #T.errs, 0)
end
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_pcall", { VAR = "err" }, {
		TRY = { b("out_print", { TEXT = b("op_add", { A = "x", B = 1 }) }) },
		CATCH = { b("out_print", { TEXT = "caught" }) } }), b("out_print", { TEXT = "after" }))
	T.interp:run(prog(a)); T.S.run(30, function() return not T.interp.running end)
	eq("pcall catches engine errors too", table.concat(T.out, ","), "caught,after")
end
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_error", { MESSAGE = "stop here" }), b("out_print", { TEXT = "never" }))
	T.interp:run(prog(a)); T.S.run(30, function() return not T.interp.running end)
	eq("uncaught error() stops and reports", T.errs[1] and T.errs[1][1], "stop here")
	eq("nothing after error", #T.out, 0)
end
print(fails == 0 and "luau OK" or ("luau FAILED " .. fails))
os.exit(fails == 0 and 0 or 1)
