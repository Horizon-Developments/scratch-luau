package.path = "tests/?.lua;" .. package.path
local H = require("harness")
local b = H.b
local reg = H.BS.newRegistry()
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end

-- Program is pure Lua: load it the same way the harness loads Lang
local Program = load(assert(io.open("src/UI/Program.lua")):read("a"), "@Program.lua", "t", setmetatable({}, { __index = _G }))()

-- ---- boolean slots
local function accepted(outer, slot, inner)
	local p = { scripts = { { blocks = { b("events_when_run"), b(outer, { [slot] = b(inner) }) } } } }
	return (H.BS.importProgram(reg, p)) ~= nil
end
eq("if <item of list>", accepted("control_if", "COND", "list_item"), true)
eq("if <item # of list>", accepted("control_if", "COND", "list_indexof"), true)
eq("while <item of list>", accepted("control_while", "COND", "list_item"), true)
eq("wait until <item # >", accepted("control_wait_until", "COND", "list_indexof"), true)
eq("if <variable> accepted (truthy)", accepted("control_if", "COND", "data_get"), true)
eq("if <list contents> still rejected", accepted("control_if", "COND", "list_contents"), false)
eq("if <length of list> still rejected", accepted("control_if", "COND", "list_length"), false)
eq("if <answer> still rejected", accepted("control_if", "COND", "sensing_answer"), false)
eq("if <1+2> still rejected", accepted("control_if", "COND", "op_add"), false)
local ifdef = reg:get("control_if")
eq("accepts(list_item) with source", reg:accepts(ifdef, "COND", "reporter", reg:get("list_item")), true)
eq("accepts(reporter) without source", reg:accepts(ifdef, "COND", "reporter"), false)
eq("number slot takes anything", reg:accepts(reg:get("op_add"), "A", "boolean"), true)

-- ---- forever is an end block
local function seq(...) return { scripts = { { blocks = { ... } } } } end
eq("forever then block rejected", (H.BS.importProgram(reg, seq(b("events_when_run"), b("control_forever"), b("out_print")))) ~= nil, false)
eq("forever last accepted", (H.BS.importProgram(reg, seq(b("events_when_run"), b("out_print"), b("control_forever")))) ~= nil, true)
eq("forever shape", reg:shapeOf(b("control_forever")), "cap")

-- ---- wrapSlot
eq("wrapSlot repeat", reg:wrapSlot(reg:createBlock("control_repeat")), "SUBSTACK")
eq("wrapSlot if_else", reg:wrapSlot(reg:createBlock("control_if_else")), "THEN")
eq("wrapSlot stack block", reg:wrapSlot(reg:createBlock("out_print")), nil)
local full = reg:createBlock("control_repeat"); full.stacks.SUBSTACK = { b("out_print") }
eq("wrapSlot filled", reg:wrapSlot(full), nil)

-- ---- Program:attach
local function P(...) return Program.new({ scripts = { ... } }) end
local function S(x, ...) return { x = x, y = 0, blocks = { ... } } end
local function ops(list) local t = {} for i, v in ipairs(list) do t[i] = v.op end return table.concat(t, " ") end

do -- mid-stack: repeat dropped after A wraps B, C
	local A, B, C = b("a"), b("b"), b("c")
	local rep = reg:createBlock("control_repeat")
	local p = P(S(0, A, B, C), S(100, rep))
	eq("after+wrap ok", p:attach(2, { kind = "after", block = A, wrap = "SUBSTACK" }), true)
	local s = p:get().scripts
	eq("after+wrap: scripts", #s, 1)
	eq("after+wrap: main", ops(s[1].blocks), "a control_repeat")
	eq("after+wrap: inside", ops(rep.stacks.SUBSTACK), "b c")
end
do -- mid-stack without wrap keeps followers after
	local A, B = b("a"), b("b")
	local p = P(S(0, A, B), S(100, b("x")))
	p:attach(2, { kind = "after", block = A })
	eq("after plain", ops(p:get().scripts[1].blocks), "a x b")
end
do -- wrap requested but the C-block's mouth is not empty: falls back to plain insert
	local A, B = b("a"), b("b")
	local rep = reg:createBlock("control_repeat"); rep.stacks.SUBSTACK = { b("q") }
	local p = P(S(0, A, B), S(100, rep))
	p:attach(2, { kind = "after", block = A, wrap = "SUBSTACK" })
	eq("wrap refused when mouth full", ops(p:get().scripts[1].blocks), "a control_repeat b")
	eq("mouth untouched", ops(rep.stacks.SUBSTACK), "q")
end
do -- held stack [repeat, x]: followers go inside repeat, x stays after it
	local A, B = b("a"), b("b")
	local rep = reg:createBlock("control_repeat")
	local p = P(S(0, A, B), S(100, rep, b("x")))
	p:attach(2, { kind = "after", block = A, wrap = "SUBSTACK" })
	eq("multi-block held stack", ops(p:get().scripts[1].blocks), "a control_repeat x")
	eq("multi-block inside", ops(rep.stacks.SUBSTACK), "b")
end
do -- forever mid-stack: followers inside forever, nothing after it
	local A, B = b("a"), b("b")
	local fe = reg:createBlock("control_forever")
	local p = P(S(0, A, B), S(100, fe))
	p:attach(2, { kind = "after", block = A, wrap = "SUBSTACK" })
	eq("forever mid-stack", ops(p:get().scripts[1].blocks), "a control_forever")
	eq("forever inside", ops(fe.stacks.SUBSTACK), "b")
end
do -- top of script: whole script goes into the mouth
	local A, B = b("a"), b("b")
	local rep = reg:createBlock("control_repeat")
	local p = P(S(0, A, B), S(100, rep))
	eq("wrap top ok", p:attach(2, { kind = "wrap", block = A, wrap = "SUBSTACK" }), true)
	local s = p:get().scripts
	eq("wrap top: one script", #s, 1)
	eq("wrap top: head", ops(s[1].blocks), "control_repeat")
	eq("wrap top: inside", ops(rep.stacks.SUBSTACK), "a b")
	eq("wrap top: position follows held block", s[1].x, 100)
end
do -- wrap kind with no usable mouth is refused and nothing moves
	local A = b("a")
	local p = P(S(0, A), S(100, b("x")))
	eq("wrap top refused", p:attach(2, { kind = "wrap", block = A, wrap = "SUBSTACK" }), false)
	eq("wrap top refused: scripts kept", #p:get().scripts, 2)
end
do -- into an occupied C-slot: old contents wrapped
	local outer = reg:createBlock("control_if"); outer.stacks.THEN = { b("m"), b("n") }
	local rep = reg:createBlock("control_repeat")
	local p = P(S(0, outer), S(100, rep))
	p:attach(2, { kind = "slot", block = outer, name = "THEN", wrap = "SUBSTACK" })
	eq("slot wrap: outer", ops(outer.stacks.THEN), "control_repeat")
	eq("slot wrap: inside", ops(rep.stacks.SUBSTACK), "m n")
end
do -- into an empty C-slot: plain
	local outer = reg:createBlock("control_if")
	local p = P(S(0, outer), S(100, b("x"), b("y")))
	p:attach(2, { kind = "slot", block = outer, name = "THEN" })
	eq("slot plain", ops(outer.stacks.THEN), "x y")
end
do -- stale target leaves everything alone
	local p = P(S(0, b("a")), S(100, reg:createBlock("control_repeat")))
	eq("stale target", p:attach(2, { kind = "after", block = b("ghost"), wrap = "SUBSTACK" }), false)
	eq("stale: scripts kept", #p:get().scripts, 2)
end

-- ---- a wrapped program runs and validates
do
	local T = H.new()
	local rep = reg:createBlock("control_repeat"); rep.inputs.TIMES = 2
	local A, B = b("out_print", { TEXT = "a" }), b("out_print", { TEXT = "b" })
	local p = P(S(0, b("events_when_run"), A, B), S(100, rep))
	p:attach(2, { kind = "after", block = p:get().scripts[1].blocks[1], wrap = "SUBSTACK" })
	local clean, err = H.BS.importProgram(T.reg, { scripts = p:get().scripts })
	eq("wrapped program validates", clean ~= nil, true)
	T.interp:run(clean); T.S.run(10, function() return not T.interp.running end)
	eq("wrapped program runs", table.concat(T.out, ","), "a,b,a,b")
end
print(fails == 0 and "placement OK" or (fails .. " FAILED"))
