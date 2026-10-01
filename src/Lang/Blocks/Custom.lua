-- "My Blocks": user-defined stack blocks, with arguments like Scratch's.
--   define {NAME} {MODE}  hat block. Its script (blocks 2..n) is the body; it never runs by itself on Run.
--   NAME is the block's text. Arguments are written in it:  (steps) = text/number argument, <flag> = boolean argument.
--       define jump (height) times <fast>   ->   call block "jump {} times <>"   (proccode "jump %s times %b")
--   MODE "without pausing" runs the body without frame yields (up to 0.5 s), like Scratch's "run without screen refresh".
--   argument / argument? reporters read the arguments of the define they sit in (by name), only inside that body.
--   <call>  call block, one registry entry per proccode ("custom:jump %s times %b"), created at runtime.
-- registry.custom.sync(scripts) keeps the registry in step with a program's scripts and returns true when the
-- palette list changed. Call it after every program change and before validating imported data.
-- registry.custom.rename(scripts, define, old, new) is called after a define's NAME changes: calls follow the
-- new proccode and argument reporters follow renamed arguments.
-- A name with no arguments has proccode = name, so saves from before arguments existed still load.
return function(R, V)
	local LIMITS = V.LIMITS
	R:defineCategory("Custom", { name = "My Blocks", color = { 255, 102, 128 } })

	local MAX_CALL_DEPTH = LIMITS.MAX_CALL_DEPTH
	local PREFIX = "custom:"
	local MODES = { "normal", "without pausing" }

	local function trim(s) return (string.match(s, "^%s*(.-)%s*$")) end

	local function nameOf(v)
		if type(v) == "string" or type(v) == "number" then
			local s = trim(V.toString(v))
			if s ~= "" then return s end
		end
	end

	-- Name text -> { code = "jump %s times %b", params = { {name="height", kind="s"}, {name="fast", kind="b"} } }.
	-- Literal text loses "%" (it would read as a marker) and runs of spaces collapse.
	local function parse(name)
		local code, params, pos = {}, {}, 1
		local function literal(text) table.insert(code, (string.gsub(text, "%%", ""))) end
		while pos <= #name do
			local s1, e1, n1 = string.find(name, "%(([^()<>]+)%)", pos)
			local s2, e2, n2 = string.find(name, "<([^()<>]+)>", pos)
			local s, e, pname, kind
			if s1 and (not s2 or s1 < s2) then s, e, pname, kind = s1, e1, n1, "s"
			elseif s2 then s, e, pname, kind = s2, e2, n2, "b" end
			if not s then literal(string.sub(name, pos)) break end
			literal(string.sub(name, pos, s - 1))
			pname = trim(pname)
			if pname == "" then literal(string.sub(name, s, e))
			else
				if #params >= LIMITS.MAX_PARAMS then literal(string.sub(name, s, e))
				else
					table.insert(params, { name = pname, kind = kind })
					table.insert(code, "%" .. kind)
				end
			end
			pos = e + 1
		end
		return { code = trim((string.gsub(table.concat(code), "%s+", " "))), params = params }
	end

	-- kinds of the %s / %b markers in a proccode, in order
	local function kindsOf(code)
		local kinds = {}
		for k in string.gmatch(code, "%%([sb])") do table.insert(kinds, k) end
		return kinds
	end

	local function defineNameOf(block)
		return nameOf(type(block.inputs) == "table" and block.inputs.NAME)
	end

	local function findDefine(program, code)
		for _, s in ipairs(program and program.scripts or {}) do
			local first = s.blocks and s.blocks[1]
			if first and first.op == "custom_define" then
				local n = defineNameOf(first)
				if n and parse(n).code == code then return s, first end
			end
		end
	end

	R:defineBlock({ id = "custom_define", category = "Custom", shape = "hat", bowler = true, label = "define {NAME} {MODE}",
		inputs = { NAME = { type = "string", default = "my block", reporters = false },
			MODE = { type = "string", default = "normal", options = MODES } },
		hat = { event = "define" } })

	-- Argument reporters. NAME is picked from the arguments of the define the reporter sits in.
	R:defineBlock({ id = "custom_arg", category = "Custom", shape = "reporter", label = "{NAME}", listed = false,
		inputs = { NAME = { type = "param", default = "" } },
		run = function(ctx, a)
			local f = ctx.thread.frame
			local v = f and f.vals[a.NAME]
			if v == nil then return 0 end
			return v
		end })
	R:defineBlock({ id = "custom_arg_bool", category = "Custom", shape = "boolean", label = "{NAME}", listed = false,
		inputs = { NAME = { type = "param", default = "" } },
		run = function(ctx, a)
			local f = ctx.thread.frame
			return f ~= nil and V.toBool(f.vals[a.NAME])
		end })

	local known = {} -- code -> def

	local function defineCall(code)
		local kinds = kindsOf(code)
		local inputs, segs, pos = {}, {}, 1
		for i, k in ipairs(kinds) do
			local s, e = string.find(code, "%%" .. k, pos)
			table.insert(segs, (string.gsub(string.sub(code, pos, s - 1), "[{}%%]", "")))
			table.insert(segs, "{P" .. i .. "}")
			inputs["P" .. i] = k == "b" and { type = "boolean" } or { type = "any", default = "" }
			pos = e + 1
		end
		table.insert(segs, (string.gsub(string.sub(code, pos), "[{}%%]", "")))
		local label = table.concat(segs)
		if string.find(label, "^%s*$") then label = "block" end
		local def = R:defineBlock({ id = PREFIX .. code, category = "Custom", shape = "stack", label = label, listed = false,
			inputs = inputs,
			run = function(ctx, args)
				local interp = ctx.interp
				local body, defBlock = findDefine(interp.program, code)
				if not body then error("\"" .. code .. "\" has no define block", 0) end
				local t = ctx.thread
				t.depth = (t.depth or 0) + 1
				if t.depth > MAX_CALL_DEPTH then error("blocks nested too deep (recursion without an end?)", 0) end
				local frame = { parent = t.frame, vals = {} }
				for i, p in ipairs(parse(defineNameOf(defBlock)).params) do frame.vals[p.name] = args["P" .. i] end
				t.frame = frame
				local warp = defBlock.inputs.MODE == "without pausing"
				if warp then interp:enterWarp(t) end
				local sig = interp:runStack(t, body.blocks, 2)
				if warp then interp:exitWarp(t) end
				t.frame = frame.parent
				t.depth = t.depth - 1
				-- "stop this script" inside a body only leaves the body; a real stop still propagates
				if sig and not ctx:alive() then return "STOP" end
			end })
		known[code] = def
		return def
	end

	local function walk(blocks, fn, depth)
		if type(blocks) ~= "table" or depth > 100 then return end
		for _, b in ipairs(blocks) do
			if type(b) == "table" then
				fn(b)
				if type(b.inputs) == "table" then
					for _, v in pairs(b.inputs) do
						if type(v) == "table" and v.op then walk({ v }, fn, depth + 1) end
					end
				end
				if type(b.stacks) == "table" then
					for _, s in pairs(b.stacks) do walk(s, fn, depth + 1) end
				end
			end
		end
	end

	local custom = {}
	R.custom = custom
	custom.parse = parse

	-- scripts: program.data.scripts (or untrusted decoded data; every access is type-checked).
	-- keepUnused: import path. Registers what the data needs but never drops calls the current program still uses.
	function custom.sync(scripts, keepUnused)
		local defined, used, anyParams, changed = {}, {}, false, false
		if type(scripts) == "table" then
			for _, s in ipairs(scripts) do
				if type(s) == "table" and type(s.blocks) == "table" then
					local first = s.blocks[1]
					if type(first) == "table" and first.op == "custom_define" then
						local n = defineNameOf(first)
						if n then
							local info = parse(n)
							defined[info.code] = true
							if #info.params > 0 then anyParams = true end
						end
					end
					walk(s.blocks, function(b)
						if type(b.op) == "string" and string.sub(b.op, 1, #PREFIX) == PREFIX then
							used[string.sub(b.op, #PREFIX + 1)] = true
						end
					end, 1)
				end
			end
		end
		for code in pairs(defined) do used[code] = true end
		local made = 0
		for code in pairs(used) do
			if not known[code] and not R:get(PREFIX .. code) then
				made = made + 1
				if made > LIMITS.MAX_CUSTOM then break end -- hostile data: the rest stay unknown and fail validation
				defineCall(code)
				changed = true
			end
		end
		if not keepUnused then -- drop call blocks nothing defines or uses (left over from rejected imports / deleted defines)
			local stale, any = {}, false
			for code in pairs(known) do
				if not used[code] then stale[PREFIX .. code] = true; any = true end
			end
			if any then
				for id in pairs(stale) do known[string.sub(id, #PREFIX + 1)] = nil end
				R:removeBlocks(stale)
				changed = true
			end
		end
		for code, def in pairs(known) do
			local listed = defined[code] == true
			if (def.listed ~= false) ~= listed then changed = true end
			def.listed = listed
		end
		-- argument reporters are only worth listing once some define has arguments
		for _, id in ipairs({ "custom_arg", "custom_arg_bool" }) do
			local def = R:get(id)
			if (def.listed ~= false) ~= anyParams then changed = true end
			def.listed = anyParams
		end
		return changed
	end

	-- A define's NAME changed from `old` to `new`. `define` is that hat block.
	--  * calls of the old proccode become calls of the new one (values of surviving argument slots are kept)
	--  * argument reporters inside the define's script follow renamed arguments (by position)
	-- Does nothing to calls when another define still uses the old proccode.
	function custom.rename(scripts, define, old, new)
		local oldInfo, newInfo = parse(nameOf(old) or ""), parse(nameOf(new) or "")
		local moved = 0
		if type(scripts) ~= "table" then return moved end

		-- argument renames inside the body
		local map = {}
		for i, p in ipairs(oldInfo.params) do
			local q = newInfo.params[i]
			if q and q.name ~= p.name then map[p.name] = q.name end
		end
		if next(map) then
			for _, s in ipairs(scripts) do
				if type(s) == "table" and type(s.blocks) == "table" and s.blocks[1] == define then
					walk(s.blocks, function(b)
						if (b.op == "custom_arg" or b.op == "custom_arg_bool") and type(b.inputs) == "table" and map[b.inputs.NAME] then
							b.inputs.NAME = map[b.inputs.NAME]
							moved = moved + 1
						end
					end, 1)
				end
			end
		end

		if oldInfo.code == newInfo.code or oldInfo.code == "" or newInfo.code == "" then return moved end
		for _, s in ipairs(scripts) do -- another define still owns the old code: leave its calls alone
			local first = type(s) == "table" and type(s.blocks) == "table" and s.blocks[1]
			if first and first ~= define and type(first) == "table" and first.op == "custom_define" then
				local n = defineNameOf(first)
				if n and parse(n).code == oldInfo.code then return moved end
			end
		end
		if not R:get(PREFIX .. newInfo.code) then defineCall(newInfo.code) end
		local newDef = R:get(PREFIX .. newInfo.code)
		local oldOp, newOp = PREFIX .. oldInfo.code, PREFIX .. newInfo.code
		for _, s in ipairs(scripts) do
			if type(s) == "table" then
				walk(s.blocks, function(b)
					if b.op == oldOp then
						local keep = type(b.inputs) == "table" and b.inputs or {}
						b.op = newOp
						b.inputs = {}
						for name, spec in pairs(newDef.inputs) do
							local v = keep[name]
							if v == nil then v = spec.default end
							b.inputs[name] = v
						end
						moved = moved + 1
					end
				end, 1)
			end
		end
		return moved
	end
end
