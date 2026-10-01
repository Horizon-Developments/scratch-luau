-- Program validation for load/import. Pure Lua. Takes UNTRUSTED decoded data and returns a clean Program
-- built through the registry (defaults filled, unknown input/stack names dropped), or (nil, "path: reason").
--   Validate.program(data, registry) -> program | nil, err
-- Rules (the same ones the editor enforces when dragging):
--   every op must exist in the registry; a stack position holds stack/hat/cap/c blocks; an input holds a
--   literal (string/number/boolean) or a reporter/boolean block that the slot accepts (registry:accepts);
--   a hat only as the first block of a script; a cap only as the last block of its stack;
--   a script may also be one loose reporter/boolean block (what dragging a reporter out onto the canvas makes).
-- Nesting is capped so hostile input cannot overflow the stack.
local Values = require(script.Parent.Values)
local LIMITS = Values.LIMITS
local Validate = { VERSION = 1 }

local MAX_DEPTH = LIMITS.MAX_DEPTH

local function isValueShape(shape) return shape == "reporter" or shape == "boolean" end

-- Cheap size check on UNTRUSTED data, run before anything is registered or built: script count, total node count
-- (incl. reporters) and depth. Returns nil or an error string.
function Validate.checkSize(data)
	if type(data) ~= "table" or type(data.scripts) ~= "table" then return nil end
	if #data.scripts > LIMITS.MAX_SCRIPTS then return "too many scripts (max " .. LIMITS.MAX_SCRIPTS .. ")" end
	local count = 0
	local function walk(b, depth)
		if type(b) ~= "table" then return nil end
		count = count + 1
		if count > LIMITS.MAX_BLOCKS then return "too many blocks (max " .. LIMITS.MAX_BLOCKS .. ")" end
		if depth > MAX_DEPTH then return "blocks nested too deep" end
		if type(b.inputs) == "table" then
			for _, v in pairs(b.inputs) do
				if type(v) == "table" then local e = walk(v, depth + 1) if e then return e end end
			end
		end
		if type(b.stacks) == "table" then
			for _, list in pairs(b.stacks) do
				if type(list) == "table" then
					for i = 1, #list do local e = walk(list[i], depth + 1) if e then return e end end
				end
			end
		end
		return nil
	end
	for i = 1, #data.scripts do
		local s = data.scripts[i]
		if type(s) == "table" and type(s.blocks) == "table" then
			for j = 1, #s.blocks do local e = walk(s.blocks[j], 1) if e then return e end end
		end
	end
	return nil
end

local stackList

local function block(reg, b, path, depth, wantValue)
	if type(b) ~= "table" then return nil, path .. ": block must be an object" end
	if depth > MAX_DEPTH then return nil, path .. ": blocks nested too deep" end
	local def = type(b.op) == "string" and reg:get(b.op)
	if not def then return nil, path .. ": unknown block " .. tostring(b.op) end
	local isValue = isValueShape(def.shape)
	if wantValue and not isValue then return nil, path .. ": " .. def.id .. " cannot go in an input" end
	if not wantValue and isValue then return nil, path .. ": " .. def.id .. " cannot be a stack block" end

	local out = reg:createBlock(b.op) -- defaults + empty stacks
	if b.inputs ~= nil and type(b.inputs) ~= "table" then return nil, path .. ": inputs must be an object" end
	for name, v in pairs(b.inputs or {}) do
		if def.inputs[name] then
			local where = path .. "." .. tostring(name)
			local t = type(v)
			if t == "table" then
				local sub, err = block(reg, v, where, depth + 1, true)
				if not sub then return nil, err end
				if not reg:accepts(def, name, reg:get(sub.op).shape, reg:get(sub.op)) then
					return nil, where .. ": " .. sub.op .. " cannot go in the " .. name .. " slot of " .. def.id
				end
				out.inputs[name] = sub
			elseif t == "string" or t == "number" or t == "boolean" then
				if t == "string" and #v > LIMITS.MAX_LITERAL then return nil, where .. ": text longer than " .. LIMITS.MAX_LITERAL .. " characters" end
				if t == "string" and b.op == "custom_define" and name == "NAME" and #v > LIMITS.MAX_NAME then
					return nil, where .. ": name longer than " .. LIMITS.MAX_NAME .. " characters"
				end
				out.inputs[name] = v
			else
				return nil, where .. ": input must be a value or a block"
			end
		end
	end

	if b.stacks ~= nil and type(b.stacks) ~= "table" then return nil, path .. ": stacks must be an object" end
	for _, name in ipairs(def.stacks) do
		local list = b.stacks and b.stacks[name]
		if list ~= nil then
			if type(list) ~= "table" then return nil, path .. "." .. name .. ": stack must be a list" end
			local seq, err = stackList(reg, list, path .. "." .. name, depth + 1, false)
			if not seq then return nil, err end
			out.stacks[name] = seq
		end
	end
	return out
end

-- A list of stack blocks. `top` = it is a whole script (a hat may lead it); inside a C-slot no hat is allowed.
function stackList(reg, list, path, depth, top)
	local seq = {}
	for i = 1, #list do
		local where = path .. "[" .. i .. "]"
		local sub, err = block(reg, list[i], where, depth, false)
		if not sub then return nil, err end
		local def = reg:get(sub.op)
		if def.shape == "hat" and not (top and i == 1) then
			return nil, where .. ": " .. def.id .. " can only start a script"
		end
		if i < #list and reg:shapeOf(sub) == "cap" then
			return nil, where .. ": nothing can follow " .. def.id
		end
		seq[i] = sub
	end
	return seq
end

function Validate.program(data, reg)
	if type(data) ~= "table" then return nil, "program must be an object" end
	if type(data.blockscript) == "number" and data.blockscript > Validate.VERSION then
		return nil, "saved by a newer BlockScript (format " .. data.blockscript .. ")"
	end
	if type(data.scripts) ~= "table" then return nil, "program has no scripts list" end
	local sizeErr = Validate.checkSize(data)
	if sizeErr then return nil, sizeErr end
	local scripts = {}
	for i = 1, #data.scripts do
		local s = data.scripts[i]
		local path = "scripts[" .. i .. "]"
		if type(s) ~= "table" or type(s.blocks) ~= "table" or #s.blocks == 0 then
			return nil, path .. ": needs a non-empty blocks list"
		end
		local blocks, err
		local only = #s.blocks == 1 and type(s.blocks[1]) == "table" and type(s.blocks[1].op) == "string" and reg:get(s.blocks[1].op)
		if only and isValueShape(only.shape) then -- a loose reporter sitting on the canvas
			local b, e = block(reg, s.blocks[1], path .. ".blocks[1]", 1, true)
			if not b then return nil, e end
			blocks = { b }
		else
			blocks, err = stackList(reg, s.blocks, path .. ".blocks", 1, true)
			if not blocks then return nil, err end
		end
		local x = type(s.x) == "number" and s.x or 0
		local y = type(s.y) == "number" and s.y or 0
		scripts[i] = { x = math.max(0, x), y = math.max(0, y), blocks = blocks }
	end
	return { scripts = scripts }
end

return Validate
