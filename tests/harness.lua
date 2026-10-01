-- Test harness: loads src/Lang under plain Lua with a fake Roblox-style script tree and a virtual scheduler.
local H = {}
-- directory listing comes from the runner (the sandbox has no io.popen)
function H.ls(dir)
	local t = {}
	for f in string.gmatch(LISTDIR(dir), "[^\n]+") do t[#t + 1] = f end
	return t
end
local ROOT = "src/Lang"

local function node(path, parent)
	local n = { __path = path, Parent = parent }
	return n
end

local cache = {}
local loadNode
local function build(dir, parent)
	local n = { __dir = dir, Parent = parent }
	for _, f in ipairs(H.ls(dir)) do
		local name = f:match("^(.-)%.lua$")
		if name and name ~= "init" then n[name] = { __file = dir .. "/" .. f, Parent = n }
		elseif not f:find("%.") then n[f] = build(dir .. "/" .. f, n) end
	end
	return n
end

function loadNode(n)
	local file = n.__file or (n.__dir .. "/init.lua")
	if cache[file] then return cache[file] end
	local src = assert(io.open(file)):read("a")
	local env = setmetatable({ script = n, require = function(x) return loadNode(x) end }, { __index = _G })
	local f = assert(load(src, "@" .. file, "t", env))
	local v = f()
	cache[file] = v
	return v
end

local tree = build(ROOT, nil)
H.BS = loadNode(tree)

-- Virtual scheduler: coroutines, a fake clock that also advances a little per read (simulated CPU).
function H.newSched(cpu)
	local S = { t = 0, ready = {}, sleepers = {}, reads = 0 }
	cpu = cpu or 0.00002
	function S.clock() S.t = S.t + cpu; return S.t end
	local function resume(co) local ok, err = coroutine.resume(co); if not ok then error(err, 0) end end
	function S.spawn(fn) local co = coroutine.create(fn); resume(co); return co end
	function S.defer(fn) local co = coroutine.create(fn); S.ready[#S.ready + 1] = co; return co end
	function S.wait(sec)
		S.sleepers[#S.sleepers + 1] = { co = coroutine.running(), at = S.t + (sec or 1 / 60) }
		coroutine.yield()
	end
	function S.turn() S.ready[#S.ready + 1] = coroutine.running(); coroutine.yield() end
	function S.cancel(co)
		for i = #S.sleepers, 1, -1 do if S.sleepers[i].co == co then table.remove(S.sleepers, i) end end
		for i = #S.ready, 1, -1 do if S.ready[i] == co then table.remove(S.ready, i) end end
	end
	-- run one frame: wake sleepers whose time has come, then drain the ready queue
	function S.frame()
		S.t = S.t + 1 / 60
		local due = {}
		for i = #S.sleepers, 1, -1 do
			if S.sleepers[i].at <= S.t then table.insert(due, 1, S.sleepers[i].co); table.remove(S.sleepers, i) end
		end
		for _, co in ipairs(due) do S.ready[#S.ready + 1] = co end
		local guard = 0
		while #S.ready > 0 do
			guard = guard + 1
			assert(guard < 1e6, "frame never ends")
			local co = table.remove(S.ready, 1)
			if coroutine.status(co) == "suspended" then resume(co) end
		end
	end
	function S.run(frames, stopWhen)
		for _ = 1, frames do S.frame(); if stopWhen and stopWhen() then return end end
	end
	return S
end

function H.new(extra)
	local S = H.newSched()
	local reg = H.BS.newRegistry()
	local out, errs = {}, {}
	local opts = { spawn = S.spawn, defer = S.defer, wait = S.wait, cancel = S.cancel, clock = S.clock, turn = S.turn,
		output = function(t) out[#out + 1] = t end,
		onError = function(m, b) errs[#errs + 1] = { m, b and b.op } end,
		date = function() return { year = 2000, month = 1, day = 2, hour = 12, min = 0, sec = 0 } end }
	for k, v in pairs(extra or {}) do opts[k] = v end
	local interp = H.BS.newInterpreter(reg, opts)
	return { S = S, reg = reg, interp = interp, out = out, errs = errs }
end

-- block helpers
function H.b(op, inputs, stacks) return { op = op, inputs = inputs or {}, stacks = stacks or {} } end
function H.script(...) return { x = 0, y = 0, blocks = { ... } } end
function H.prog(...) return { scripts = { ... } } end
return H
