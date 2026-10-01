package.path = "tests/?.lua;" .. package.path
local H = require("harness")
local b, script, prog = H.b, H.script, H.prog
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end
local function join(t) return table.concat(t, ",") end

-- 1. broadcast restarts a running receiver
do
	local T = H.new()
	local recv = script(b("events_when_broadcast", { MESSAGE = "go" }),
		b("out_print", { TEXT = "start" }), b("control_wait", { SECS = 0.5 }), b("out_print", { TEXT = "end" }))
	local sender = script(b("events_when_run"), b("events_broadcast", { MESSAGE = "go" }),
		b("control_wait", { SECS = 0.1 }), b("events_broadcast", { MESSAGE = "go" }))
	T.interp:run(prog(sender, recv))
	T.S.run(200, function() return not T.interp.running end)
	eq("restart: prints", join(T.out), "start,start,end")
	eq("restart: run finished", T.interp.running, false)
end

-- 2. key hat is ignored while its script runs
do
	local T = H.new()
	local k = script(b("events_when_key", { KEY = "a" }), b("out_print", { TEXT = "k" }), b("control_wait", { SECS = 0.5 }))
	T.interp:run(prog(k))
	T.S.run(2)
	T.interp:fire("key", "a"); T.S.run(2); T.interp:fire("key", "a"); T.S.run(60); T.interp:fire("key", "a"); T.S.run(2)
	eq("key once: prints", join(T.out), "k,k")
	T.interp:stop()
end

-- 3. two forevers interleave, loops hand out turns
do
	local T = H.new()
	local f1 = script(b("events_when_run"), b("control_forever", {}, { SUBSTACK = { b("out_print", { TEXT = "a" }) } }))
	local f2 = script(b("events_when_run"), b("control_forever", {}, { SUBSTACK = { b("out_print", { TEXT = "b" }) } }))
	T.interp:run(prog(f1, f2))
	T.S.run(2)
	T.interp:stop()
	local alt = true
	for i = 1, math.min(#T.out, 20) do if T.out[i] ~= (i % 2 == 1 and "a" or "b") then alt = false end end
	eq("interleave: alternates", alt, true)
	eq("interleave: many per frame", #T.out > 50, true)
end

-- 4. deep recursion: count (n): if n > 0 { change x by 1; count (n - 1) }
local function recursion(depth)
	local T = H.new()
	local def = script(b("custom_define", { NAME = "count (n)", MODE = "normal" }),
		b("control_if", { COND = b("op_gt", { A = b("custom_arg", { NAME = "n" }), B = 0 }) }, { THEN = {
			b("data_change", { NAME = "x", BY = 1 }),
			b("custom:count %s", { P1 = b("op_sub", { A = b("custom_arg", { NAME = "n" }), B = 1 }) }) } }))
	local main = script(b("events_when_run"), b("data_set", { NAME = "x", VALUE = 0 }),
		b("custom:count %s", { P1 = depth }), b("out_print", { TEXT = b("data_get", { NAME = "x" }) }))
	local p = prog(main, def)
	T.reg.custom.sync(p.scripts)
	T.interp:run(p)
	T.S.run(2000, function() return not T.interp.running end)
	return T
end
do
	local T = recursion(200)
	eq("recursion 200 output", join(T.out), "200")
	eq("recursion 200 no errors", #T.errs, 0)
	local T2 = recursion(100000)
	eq("recursion runaway is an error, not a crash", #T2.errs, 1)
	print("     ", T2.errs[1] and T2.errs[1][1], T2.errs[1] and T2.errs[1][2])
end

-- 5. warp length
do
	local T = H.new()
	eq("WARP_SECONDS", H.BS.Values.LIMITS.WARP_SECONDS, 0.5)
end

-- 6. all at once = plain stack (frames advance per loop iteration like a normal loop)
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_all_at_once", {}, { SUBSTACK = {
		b("control_repeat", { TIMES = 3 }, { SUBSTACK = { b("out_print", { TEXT = "x" }) } }) } }))
	T.interp:run(prog(a)); T.S.run(5, function() return not T.interp.running end)
	eq("all at once runs contents", join(T.out), "x,x,x")
end

-- 7. numeric for reads VALUE once (Luau `for i = 1, n`): changing n inside the loop changes nothing
do
	local T = H.new()
	local a = script(b("events_when_run"), b("data_set", { NAME = "n", VALUE = 5 }),
		b("control_for_each", { VAR = "i", VALUE = b("data_get", { NAME = "n" }) }, { SUBSTACK = {
			b("data_set", { NAME = "n", VALUE = 2 }), b("out_print", { TEXT = b("data_get", { NAME = "i" }) }) } }))
	T.interp:run(prog(a)); T.S.run(20, function() return not T.interp.running end)
	eq("for reads limit once", join(T.out), "1,2,3,4,5")
end

-- 8. variables/lists persist across runs; resetData clears
do
	local T = H.new()
	local a = script(b("events_when_run"), b("out_print", { TEXT = b("data_get", { NAME = "v" }) }), b("data_set", { NAME = "v", VALUE = 1 }),
		b("list_add", { ITEM = "z", LIST = "L" }))
	T.interp:run(prog(a)); T.S.run(3)
	T.interp:run(prog(a)); T.S.run(3)
	eq("persist vars (unset is nil, then 1)", join(T.out), "nil,1")
	eq("persist list", #T.interp.lists.L, 2)
	T.interp:resetData()
	eq("resetData", next(T.interp.vars), nil)
end

-- 9. stop other scripts: run still finishes
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_forever", {}, { SUBSTACK = { b("control_wait", { SECS = 0.05 }) } }))
	local c = script(b("events_when_run"), b("control_wait", { SECS = 0.1 }), b("control_stop", { OPTION = "other scripts" }))
	T.interp:run(prog(a, c))
	T.S.run(60, function() return not T.interp.running end)
	eq("stop other scripts finishes run", T.interp.running, false)
end

-- 10. error marks the innermost block
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_repeat", { TIMES = 2 }, { SUBSTACK = { b("out_print", { TEXT = "ok" }), b("NOPE") } }))
	T.interp:run(prog(a)); T.S.run(3)
	eq("unknown block error", T.errs[1] and T.errs[1][2], "NOPE")
	eq("error stops run", T.interp.running, false)
end

-- 11. warp body keeps running across iterations without a frame wait
do
	local T = H.new()
	local a = script(b("events_when_run"), b("control_all_at_once", {}, {}), b("out_print", { TEXT = "end" }))
	T.interp:run(prog(a)); T.S.run(2); eq("all at once empty", join(T.out), "end")
end

-- 12. loop of 1000 with one thread finishes in a few frames (not 1000 frames)
do
	local T = H.new()
	local a = script(b("events_when_run"), b("data_set", { NAME = "c", VALUE = 0 }), b("control_repeat", { TIMES = 1000 }, { SUBSTACK = { b("data_change", { NAME = "c", BY = 1 }) } }))
	local frames = 0
	T.interp:run(prog(a))
	while T.interp.running and frames < 1000 do T.S.frame(); frames = frames + 1 end
	eq("1000-iteration loop", T.interp.vars.c, 1000)
	print("     frames used:", frames)
end
print(fails == 0 and "interp OK" or (fails .. " FAILED"))
