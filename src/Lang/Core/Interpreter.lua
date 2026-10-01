-- Block interpreter. No rendering. Pure Lua; scheduler is injectable.
--
-- Program = { scripts = { { x=0, y=0, blocks = { block, ... } }, ... } }
-- Block   = { op = "id", inputs = { NAME = literal | Block }, stacks = { NAME = { Block, ... } } }
-- A script whose first block is a hat only starts when that hat's event fires.
--
-- opts: output(text, kind)  clear()  ask(prompt)->string  onError(msg, block)  onFinish()
--       spawn(fn)->handle  wait(sec)  clock()->seconds  budget (blocks between forced yields, default 500)
--       defer(fn)->handle  (first slice of every thread; default task.defer; none = run the first slice at once)
--       cancel(handle)     (stop() kills sleeping threads; default task.cancel; none = stopped flag + <=0.1 s sleep slices)
--       keyDown(name)->bool  mouseDown()->bool  date()->{year,month,day,hour,min,sec} (LOCAL time; default DateTime local, else os.date)
--       turn()             (give other ready scripts a turn without waiting a frame; default: defer + yield; none = no turn)
-- Host events: interp:fire("key", name) while running starts the matching "when key pressed" scripts.
-- Variables, lists, the counter and the answer live across runs (like a Scratch project); interp:resetData() clears them.
-- A hat that fires while its script is running restarts that script (broadcast, Run) or is ignored (key, timer edge), like Scratch.
--
-- Limits (Values.LIMITS): live threads, thread starts per frame, ONE CPU allowance per frame shared by all threads
-- (a "frame" is a FRAME_WINDOW span of opts.clock), warp length, nesting depth, print length/rate, value sizes.
local Values = require(script.Parent.Values)

local Interpreter = {}
Interpreter.__index = Interpreter

local LIMITS = Values.LIMITS
local SLEEP_SLICE = 0.1 -- longest single wait(); longer sleeps are chopped so Stop is noticed without task.cancel

-- Days since 1970-01-01 for a civil date (no os.time, so it does not depend on the host time zone).
local function daysFromCivil(y, m, d)
	if m <= 2 then y = y - 1 end
	local era = math.floor(y / 400)
	local yoe = y - era * 400
	local doy = math.floor((153 * (m + (m > 2 and -3 or 9)) + 2) / 5) + d - 1
	local doe = yoe * 365 + math.floor(yoe / 4) - math.floor(yoe / 100) + doy
	return era * 146097 + doe - 719468
end

-- Context handed to every block's run(ctx, args)
local Context = {}
Context.__index = Context
function Context:stack(name) return self.interp:runStack(self.thread, self.block.stacks[name] or {}) end
function Context:input(name) return self.interp:evalInput(self.thread, self.block, name) end -- for lazy inputs
function Context:alive() return not (self.thread.stopped or self.interp.halted) end
function Context:tick() self.interp:tick(self.thread) end
function Context:loopStep() self.interp:loopStep(self.thread) end -- call at the end of every loop iteration
function Context:yield() self.interp:pause(self.thread) end
function Context:warp(on) if on then self.interp:enterWarp(self.thread) else self.interp:exitWarp(self.thread) end end
function Context:stopOthers() self.interp:stopOthers(self.thread) end
function Context:wait(sec) self.interp:sleep(self.thread, sec) end
function Context:say(text, kind) self.interp:say(text, kind) end
function Context:stopAll() self.interp:stop() end

function Interpreter.new(registry, opts)
	opts = opts or {}
	local self = setmetatable({}, Interpreter)
	self.registry = registry
	self.opts = opts
	self.spawn = opts.spawn or (task and task.spawn) or function(f) f() end
	self.defer = opts.defer or (task and task.defer) or nil
	self.cancel = opts.cancel or (task and task.cancel) or nil
	self.turn = opts.turn or (task and task.defer and function()
		local co = coroutine.running()
		task.defer(co)
		coroutine.yield()
	end) or nil
	self.wait = opts.wait or (task and task.wait) or function() end
	self.clock = opts.clock or os.clock
	self.budget = opts.budget or 500
	self.vars, self.lists, self.threads, self.watchers = {}, {}, {}, {}
	self.program, self.halted, self.running = nil, false, false
	self.active, self.steps, self.answer, self.timerStart, self.runId = 0, 0, "", 0, 0
	self.counter = 0
	self.nthreads, self.starts, self.lines, self.frameStart = 0, 0, 0, nil
	self.uncounted, self.throttled = false, false
	return self
end

-- Frame accounting. A "frame" is a FRAME_WINDOW span of the clock: the first check after the window has passed opens a
-- new one and resets the per-frame counters (thread starts, print lines). Returns the clock reading.
function Interpreter:_frameCheck()
	local now = self.clock()
	local fs = self.frameStart
	if fs == nil or now < fs or now - fs >= LIMITS.FRAME_WINDOW then
		self.frameStart, self.starts, self.lines = now, 0, 0
	end
	return now
end

-- True once all threads together have used their FRAME_SECONDS of this frame.
function Interpreter:_overBudget()
	local now = self:_frameCheck()
	return now - self.frameStart >= LIMITS.FRAME_SECONDS
end

-- Print: long lines are cut, and at most MAX_LINES_PER_FRAME lines per frame get through (then one notice per run).
function Interpreter:say(text, kind)
	local s = Values.toString(text)
	if #s > LIMITS.MAX_PRINT then
		local cut = LIMITS.MAX_PRINT
		while cut > 0 do -- do not cut inside a UTF-8 sequence
			local b = string.byte(s, cut + 1)
			if b and b >= 0x80 and b < 0xC0 then cut = cut - 1 else break end
		end
		s = string.sub(s, 1, cut) .. "..."
	end
	self:_frameCheck()
	self.lines = self.lines + 1
	if self.lines > LIMITS.MAX_LINES_PER_FRAME then
		if self.throttled then return end
		self.throttled, s, kind = true, "output throttled (too many lines per frame)", "say"
	end
	if self.opts.output then self.opts.output(s, kind or "say") else print(s) end
end

-- Variables and lists live here so every block module shares the same caps.
function Interpreter:setVar(name, value)
	local vars = self.vars
	if vars[name] == nil then
		if #name > LIMITS.MAX_NAME then error("name too long", 0) end
		local n = 0
		for _ in pairs(vars) do n = n + 1 end
		if n >= LIMITS.MAX_VARS then error("too many variables", 0) end
	end
	vars[name] = Values.limitString(value)
end

function Interpreter:list(name)
	local l = self.lists[name]
	if l then return l end
	if #name > LIMITS.MAX_NAME then error("name too long", 0) end
	local n = 0
	for _ in pairs(self.lists) do n = n + 1 end
	if n >= LIMITS.MAX_LISTS then error("too many lists", 0) end
	l = {}
	self.lists[name] = l
	return l
end

-- Call before growing list l by one item holding `item`.
function Interpreter:checkListGrow(l, item)
	Values.limitString(item)
	if #l >= LIMITS.MAX_LIST then error("list too long", 0) end
	local total = 0
	for _, other in pairs(self.lists) do total = total + #other end
	if total >= LIMITS.MAX_LISTS_TOTAL_ITEMS then error("too many list items", 0) end
end

function Interpreter:timer() return self.clock() - self.timerStart end
function Interpreter:resetTimer() self.timerStart = self.clock() end

-- "Without pausing" bodies (custom block option, all at once): no frame yields until WARP_SECONDS has passed or the
-- shared frame allowance is used up.
function Interpreter:enterWarp(thread)
	if (thread.warp or 0) == 0 then thread.warpStart = self.clock() end
	thread.warp = (thread.warp or 0) + 1
end

function Interpreter:exitWarp(thread)
	thread.warp = math.max(0, (thread.warp or 0) - 1)
end

-- A frame yield that warp mode may skip.
function Interpreter:pause(thread)
	if thread and (thread.warp or 0) > 0 then
		if self.clock() - thread.warpStart < LIMITS.WARP_SECONDS then return end
		thread.warpStart = self.clock()
	end
	self.wait()
	self:_frameCheck()
end

-- Every executed block ticks: a forced yield every `budget` blocks, and a yield whenever the frame allowance that all
-- threads share is used up (checked every 16 blocks to keep the clock off the hot path).
function Interpreter:tick(thread)
	self.steps = self.steps + 1
	if self.steps >= self.budget then
		self.steps = 0
		self:pause(thread)
	elseif self.steps % 16 == 0 and self:_overBudget() then
		self:pause(thread)
	end
end

-- End of one loop iteration. Scratch runs every thread once per pass, so a loop hands the turn to the other ready
-- scripts here; the frame only ends (a real wait) once the shared CPU allowance is used up. Warp bodies keep going.
function Interpreter:loopStep(thread)
	self:tick(thread)
	if (thread.warp or 0) > 0 then return end
	if self:_overBudget() then
		self.steps = 0
		self.wait()
		self:_frameCheck()
	elseif self.turn then
		self.turn()
	end
end

-- Forget variables, lists, the counter and the answer (they otherwise carry over from run to run).
function Interpreter:resetData()
	self.vars, self.lists, self.counter, self.answer = {}, {}, 0, ""
end

-- Sleep for `sec` seconds in slices of at most SLEEP_SLICE, so a stopped run is noticed within 0.1 s even when the
-- host cannot cancel the thread.
function Interpreter:sleep(thread, sec)
	local left, first = sec, true
	while first or left > 0 do
		first = false
		local s = left < SLEEP_SLICE and left or SLEEP_SLICE
		self.wait(s)
		left = left - s
		if thread.stopped or self.halted then return end
	end
end

function Interpreter:stopOthers(current)
	local doomed = {}
	for thread in pairs(self.threads) do
		if thread ~= current then doomed[#doomed + 1] = thread end
	end
	for _, thread in ipairs(doomed) do self:_kill(thread) end
end

-- Stop one thread and take it out of the live count (its coroutine may never run to its end).
function Interpreter:_kill(thread)
	thread.stopped = true
	if not thread.asking then self:_cancel(thread.handle) end
	self:_retire(thread)
end

-- Take a finished or killed thread out of the counts, once. Ends the run when it was the last one.
function Interpreter:_retire(thread)
	if thread.retired then return end
	thread.retired, thread.done = true, true
	if thread.runId ~= self.runId then return end -- a newer run replaced this one
	if self.threads[thread] then
		self.threads[thread] = nil
		self.nthreads = self.nthreads - 1
	end
	self.active = self.active - 1
	if self.active == 0 then self:_finish() end
end

-- The live thread running `script`, if any.
function Interpreter:_threadFor(script)
	for thread in pairs(self.threads) do
		if thread.script == script and not thread.retired then return thread end
	end
end

-- Local wall-clock date. The host may supply opts.date (Roblox os.date is UTC); wday is always derived here.
function Interpreter:localDate()
	local d = self.opts.date and self.opts.date()
	if not d and DateTime then -- Roblox: os.date is UTC, DateTime has the local zone
		local l = DateTime.now():ToLocalTime()
		d = { year = l.Year, month = l.Month, day = l.Day, hour = l.Hour, min = l.Minute, sec = l.Second }
	end
	d = d or os.date("*t")
	local days = daysFromCivil(d.year, d.month, d.day)
	return { year = d.year, month = d.month, day = d.day, wday = (days + 4) % 7 + 1,
		hour = d.hour or 0, min = d.min or 0, sec = d.sec or 0, days = days }
end

function Interpreter:daysSince2000()
	local d = self:localDate()
	return d.days - daysFromCivil(2000, 1, 1) + (d.hour * 3600 + d.min * 60 + d.sec) / 86400
end

function Interpreter:keyDown(name) return self.opts.keyDown ~= nil and self.opts.keyDown(name) == true end
function Interpreter:mouseDown() return self.opts.mouseDown ~= nil and self.opts.mouseDown() == true end

function Interpreter:fail(msg, blk)
	self:stop()
	if self.opts.onError then self.opts.onError(tostring(msg), blk) else warn("[BlockScript] " .. tostring(msg)) end
end

function Interpreter:_finish()
	if not self.running then return end
	self.running = false
	if self.opts.onFinish then self.opts.onFinish() end
end

-- Kill a sleeping thread when the host can (task.cancel). Never the running one: it unwinds on its own.
function Interpreter:_cancel(handle)
	if handle ~= nil and self.cancel and handle ~= coroutine.running() then pcall(self.cancel, handle) end
end

function Interpreter:stop()
	self.halted = true
	for thread in pairs(self.threads) do
		thread.stopped, thread.retired = true, true
		if not thread.asking then self:_cancel(thread.handle) end -- a thread inside ask() is resumed by the prompt, then unwinds
	end
	for _, h in ipairs(self.watchers) do self:_cancel(h) end
	self.threads, self.watchers, self.nthreads = {}, {}, 0
	self:_finish()
end

-- Evaluate one block (stack block -> signal, reporter -> value). Errors are plain Lua errors that unwind the whole
-- thread (no pcall per block, so nesting depth is not limited by the C stack); thread.cur names the block that raised.
function Interpreter:execBlock(thread, blk)
	local def = self.registry:get(blk.op)
	if not def then
		thread.cur = blk
		error("Unknown block: " .. tostring(blk.op), 0)
	end
	local depth = (thread.execDepth or 0) + 1
	if depth > LIMITS.MAX_EXEC_DEPTH then
		thread.cur = blk
		error("blocks nested too deep", 0)
	end
	thread.execDepth = depth
	local prev = thread.cur
	thread.cur = blk
	local ctx = setmetatable({ interp = self, thread = thread, block = blk, def = def }, Context)
	local args = {}
	for name, spec in pairs(def.inputs) do
		if not spec.lazy then args[name] = self:evalInput(thread, blk, name) end
	end
	local res
	if not (self.halted or thread.stopped) then
		self:tick(thread)
		res = def.run(ctx, args)
	end
	thread.execDepth = depth - 1
	thread.cur = prev
	return res
end

function Interpreter:evalInput(thread, blk, name)
	local def = self.registry:get(blk.op)
	local spec = def.inputs[name]
	local v = blk.inputs[name]
	if type(v) == "table" and v.op then v = self:execBlock(thread, v) end
	if spec.raw then return v end -- raw: the block gets the value untouched (Luau and / or, tonumber, ...)
	return Values.coerce(spec.type, v)
end

-- Returns "STOP" if the script asked to stop, else nil.
function Interpreter:runStack(thread, stack, from)
	for i = from or 1, #stack do
		if thread.stopped or self.halted then return "STOP" end
		local sig = self:execBlock(thread, stack[i])
		if sig then return sig end
	end
	return nil
end

-- Run fn as a new host thread and return its handle. `deferred` = the caller is itself a running thread (or a poller):
-- the first slice must not run inside the caller. With task.defer that is one call; without it the new thread waits
-- one frame before it begins.
function Interpreter:_launch(fn, deferred)
	if self.defer then return self.defer(fn) end
	if deferred then return self.spawn(function() self.wait() fn() end) end
	return self.spawn(fn)
end

-- Returns the new thread, or nil after failing the run with "too many scripts running".
function Interpreter:_startThread(script, from, deferred)
	if self.nthreads >= LIMITS.MAX_THREADS then
		self:fail("too many scripts running")
		return nil
	end
	if not self.uncounted then
		self:_frameCheck()
		self.starts = self.starts + 1
		if self.starts > LIMITS.MAX_STARTS_PER_FRAME then
			self:fail("too many scripts running")
			return nil
		end
	end
	local thread = { stopped = false, done = false, script = script, runId = self.runId }
	self.threads[thread] = true
	self.nthreads = self.nthreads + 1
	self.active = self.active + 1
	local runId = self.runId
	thread.handle = self:_launch(function()
		if thread.stopped or self.halted or runId ~= self.runId then return end
		self:_frameCheck()
		local ok, err = pcall(self.runStack, self, thread, script.blocks, from)
		if not ok and not self.halted and runId == self.runId then self:fail(err, thread.cur) end
		self:_retire(thread)
	end, deferred)
	return thread
end

local function hatArgs(self, first, def)
	local probe, args = { stopped = false }, {}
	for name in pairs(def.inputs) do args[name] = self:evalInput(probe, first, name) end
	return args
end

-- Edge-triggered hats (hat.poll, e.g. "when timer > 5"): one watcher loop each, started by run().
-- A program with any persistent hat (poll or hat.persistent) stays "running" until Stop, like a Scratch project.
function Interpreter:_startWatchers()
	local persistent = false
	local runId = self.runId
	for _, script in ipairs(self.program.scripts) do
		local first = script.blocks[1]
		local def = first and self.registry:get(first.op)
		if def and def.shape == "hat" and (def.hat.persistent or def.hat.poll) then
			persistent = true
			if def.hat.poll then
				local h = self:_launch(function()
					local prev = false
					while not self.halted and runId == self.runId do
						if not self:_threadFor(script) then -- not evaluated while its script runs (an edge hat never restarts)
							local ok, now = pcall(function() return def.hat.poll(hatArgs(self, first, def), self) end)
							if not ok then self:fail(now, first) return end
							if now and not prev then self:_startThread(script, 2, true) end
							prev = now and true or false
						end
						self.wait()
					end
				end, false)
				if h ~= nil then table.insert(self.watchers, h) end
			end
		end
	end
	if persistent then self.active = self.active + 1 end -- released only by stop()
end

-- Fire an event ("run", "broadcast", ...). `caller` is the thread that fired it (broadcast blocks pass theirs): its
-- receivers then start deferred. Returns the list of threads started.
function Interpreter:fire(event, payload, caller)
	local started = {}
	if not self.program then return started end
	for _, script in ipairs(self.program.scripts) do
		local first = script.blocks[1]
		local def = first and self.registry:get(first.op)
		if def and def.shape == "hat" and def.hat.event == event then
			local pass = true
			if def.hat.filter then
				local ok, res = pcall(function() return def.hat.filter(hatArgs(self, first, def), payload) end)
				if not ok then self:fail(res, first) break end
				pass = res
			end
			if pass then
				local existing = self:_threadFor(script)
				if existing and def.hat.once then
					pass = false -- already running: this trigger is ignored
				elseif existing then
					self:_kill(existing) -- already running: start over from the top
				end
			end
			if pass then
				local t = self:_startThread(script, 2, caller ~= nil)
				if not t then break end -- the run failed (too many scripts)
				table.insert(started, t)
			end
		end
	end
	return started
end

function Interpreter:run(program)
	self:stop()
	self.program = program
	self.runId = self.runId + 1
	self.threads, self.watchers = {}, {}
	self.halted, self.running, self.active, self.steps = false, true, 1, 0
	self.nthreads, self.starts, self.lines, self.frameStart, self.throttled = 0, 0, 0, nil, false
	self:resetTimer()
	self.uncounted = true -- the initial start of every "when Run clicked" script is not rate limited
	self:fire("run")
	self.uncounted = false
	if not self.halted then self:_startWatchers() end
	self.active = self.active - 1 -- release start guard
	if self.active == 0 then self:_finish() end
end

return Interpreter
