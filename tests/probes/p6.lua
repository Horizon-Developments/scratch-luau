local C = dofile("tests/probes/common.lua")
local function count(t) local n=0 for _ in pairs(t) do n=n+1 end return n end
print("== P6 warp: longest uninterrupted CPU slice (real os.clock, frame yield = coroutine.yield)")
do
  local reg = C.newRegistry(); local B = C.B(reg)
  local maxSlice, last, frames = 0, nil, 0
  local q = {}
  local function spawn(f) local co = coroutine.create(f) local ok, e = coroutine.resume(co) assert(ok, e) if coroutine.status(co) == "suspended" then q[#q+1] = co end end
  local interp = C.Interpreter.new(reg, { spawn = spawn, wait = function() coroutine.yield() end, clock = os.clock, onError = print })
  -- forever inside "all at once"
  interp:run({ scripts = { { x=0,y=0, blocks = { B("events_when_run"), B("control_all_at_once", {}, { SUBSTACK = { B("control_forever", {}, { SUBSTACK = { B("control_incr_counter") } }) } }) } } } })
  -- the run() above already executed the first slice up to the first real yield; measure subsequent slices
  for f = 1, 3 do
    local t0 = os.clock()
    local co = table.remove(q, 1); local ok, e = coroutine.resume(co); assert(ok, e)
    if coroutine.status(co) == "suspended" then q[#q+1] = co end
    print(string.format("  frame %d: one resume ran %.3f s, %d blocks so far", f, os.clock() - t0, interp.counter))
  end
end
print("== P6b: N such threads share one frame (each gets its own 0.5 s slice)")
do
  local reg = C.newRegistry(); local B = C.B(reg)
  local q = {}
  local function spawn(f) local co = coroutine.create(f) local ok, e = coroutine.resume(co) assert(ok, e) if coroutine.status(co) == "suspended" then q[#q+1] = co end end
  local interp = C.Interpreter.new(reg, { spawn = spawn, wait = function() coroutine.yield() end, clock = os.clock, onError = print })
  local scripts = {}
  for i = 1, 4 do scripts[i] = { x=0,y=0, blocks = { B("events_when_run"), B("control_all_at_once", {}, { SUBSTACK = { B("control_forever", {}, { SUBSTACK = { B("control_incr_counter") } }) } }) } } end
  interp:run({ scripts = scripts })
  local t0 = os.clock()
  local n = #q
  for i = 1, n do local co = table.remove(q, 1) local ok, e = coroutine.resume(co) assert(ok, e) q[#q+1] = co end
  print(string.format("  one frame with %d warp threads: %.2f s of uninterrupted CPU", n, os.clock() - t0))
end

print("== P7 memory: string doubling and list growth have no caps")
do
  local reg, rt = C.newRegistry(), C.newRuntime(); local B = C.B(reg)
  local interp = C.Interpreter.new(reg, { spawn = rt.spawn, wait = rt.wait, clock = rt.clock, onError = print })
  -- set s to "ab"; repeat 24: set s to (join s s)
  interp:run({ scripts = { { x=0,y=0, blocks = { B("events_when_run"), B("data_set", { NAME = "s", VALUE = "ab" }),
    B("control_repeat", { TIMES = 24 }, { SUBSTACK = { B("data_set", { NAME = "s", VALUE = B("op_join", { A = B("data_get", { NAME = "s" }), B = B("data_get", { NAME = "s" }) }) }) } }) } } } })
  local t = os.clock()
  local frames = 0
  while #rt.q > 0 do local e = table.remove(rt.q, 1) rt.now = e.t rt.resume(e) frames = frames + 1 end
  print(string.format("  24 doublings -> string of %d bytes (%.1f MB) in %.2fs; 40 iterations would be 2 TB; 31 would be ~4 GB (Luau string limit = INT_MAX)", #interp.vars.s, #interp.vars.s/2^20, os.clock()-t))
  -- op_letter / length are O(n) allocations
  local t = os.clock()
  local letter = reg:get("op_letter").run
  for i = 1, 20 do letter(nil, { N = 1, S = interp.vars.s }) end
  print(string.format("  20 x 'letter 1 of s' on a %.0f MB string: %.2fs (allocates a table of every character each call)", #interp.vars.s/2^20, os.clock()-t))
end
