-- Program model, separate from views. Shape matches the interpreter:
--   { scripts = { { x, y, blocks = { Block, ... } }, ... } }
-- Views subscribe with onChanged and re-render from :get(). Steps 3-5 mutate through these methods.
local Program = {}
Program.__index = Program

function Program.new(data)
	return setmetatable({ data = data or { scripts = {} }, listeners = {} }, Program)
end

function Program:get() return self.data end

function Program:onChanged(fn)
	table.insert(self.listeners, fn)
end

function Program:changed()
	for _, fn in ipairs(self.listeners) do fn(self.data) end
end

function Program:addScript(block, x, y, quiet)
	table.insert(self.data.scripts, { x = x, y = y, blocks = { block } })
	if not quiet then self:changed() end
	return #self.data.scripts
end

function Program:count() return #self.data.scripts end

-- Swaps the whole program (load). `data` must already be validated.
function Program:replace(data)
	self.data = data
	self:changed()
end

function Program:clear()
	self.data = { scripts = {} }
	self:changed()
end

local function locate(blocks, target)
  for i, b in ipairs(blocks) do
    if b == target then return blocks, i end
    for _, sub in pairs(b.stacks) do
      local arr, idx = locate(sub, target)
      if arr then return arr, idx end
    end
  end
end

function Program:find(block)
  for i, s in ipairs(self.data.scripts) do
    local arr, idx = locate(s.blocks, block)
    if arr then return arr, idx, i end
  end
end

-- Returns the index of a script that starts at `block`, splitting it (and everything below) out of its stack if needed.
function Program:detach(block, x, y)
  local arr, idx, i = self:find(block)
  if idx == 1 and arr == self.data.scripts[i].blocks then return i end
  local moved = table.move(arr, idx, #arr, 1, {})
  for j = #arr, idx, -1 do arr[j] = nil end
  table.insert(self.data.scripts, { x = x, y = y, blocks = moved })
  self:changed()
  return #self.data.scripts
end

-- Nested reporter lookup: returns (parentBlock, inputName) if `target` sits in an input slot.
local function locateInput(blocks, target)
  for _, b in ipairs(blocks) do
    for name, v in pairs(b.inputs) do
      if v == target then return b, name end
      if type(v) == "table" and v.op then
        local p, n = locateInput({ v }, target)
        if p then return p, n end
      end
    end
    for _, sub in pairs(b.stacks) do
      local p, n = locateInput(sub, target)
      if p then return p, n end
    end
  end
end

function Program:findInput(block)
  for _, s in ipairs(self.data.scripts) do
    local p, n = locateInput(s.blocks, block)
    if p then return p, n end
  end
end

-- Pulls a reporter out of its input slot into a new script of its own (slot gets `default` back).
function Program:detachInput(block, x, y, default)
  local parent, name = self:findInput(block)
  if not parent then return nil end
  parent.inputs[name] = default
  table.insert(self.data.scripts, { x = x, y = y, blocks = { block } })
  self:changed()
  return #self.data.scripts
end

-- Merges scripts[index] into `target` and removes it as a separate script. target is one of:
--   { kind = "after",  block = B }          insert below stack block B
--   { kind = "before", block = F }          put on top of the script that starts with F
--   { kind = "slot",   block = P, name = N } insert at the top of P's C-slot N
--   { kind = "wrap",   block = F, wrap = W } the held C-block takes the whole script that starts with F into its slot W
--   { kind = "input",  block = P, name = N } plug a reporter/boolean into P's input N
-- `wrap = W` on "after" / "slot": the held stack's first block is a C-block with an empty slot W, and the blocks the
-- drop displaces (the ones below B, or the slot's old contents) go inside that slot instead of after the held stack.
function Program:attach(index, target)
	local script = self.data.scripts[index]
	if not script or not target or not target.block or locate(script.blocks, target.block) then return false end
	local wrap = target.wrap
	if wrap ~= nil then
		local first = script.blocks[1]
		local slot = type(first) == "table" and type(first.stacks) == "table" and first.stacks[wrap]
		if type(slot) ~= "table" or #slot > 0 then
			if target.kind == "wrap" then return false end
			wrap = nil
		end
	elseif target.kind == "wrap" then
		return false
	end
	-- Resolve the target BEFORE touching the program, so a stale target (block no longer in the program) leaves
	-- the dragged script where it was.
	local destArr, destIdx, destScript
	if target.kind == "after" then
		destArr, destIdx = self:find(target.block)
		if not destArr then return false end
	elseif target.kind == "before" or target.kind == "wrap" then
		local arr, idx, si = self:find(target.block)
		if not arr or idx ~= 1 or arr ~= self.data.scripts[si].blocks then return false end
		destScript = self.data.scripts[si]
	elseif target.kind == "slot" then
		if not self:scriptOf(target.block) then return false end
	elseif target.kind == "input" then
		if not self:scriptOf(target.block) or #script.blocks ~= 1 then return false end
	else
		return false
	end
	if destScript == script then return false end
	table.remove(self.data.scripts, index)
	local moving = script.blocks
	if target.kind == "after" then
		if wrap then
			local followers = table.move(destArr, destIdx + 1, #destArr, 1, {})
			for j = #destArr, destIdx + 1, -1 do destArr[j] = nil end
			if #followers > 0 then moving[1].stacks[wrap] = followers end
		end
		for i, b in ipairs(moving) do table.insert(destArr, destIdx + i, b) end
	elseif target.kind == "before" then
		for i = #moving, 1, -1 do table.insert(destScript.blocks, 1, moving[i]) end
		destScript.x, destScript.y = script.x, script.y
	elseif target.kind == "wrap" then
		moving[1].stacks[wrap] = destScript.blocks
		destScript.blocks = moving
		destScript.x, destScript.y = script.x, script.y
	elseif target.kind == "slot" then
		local list = target.block.stacks[target.name]
		if not list then list = {}; target.block.stacks[target.name] = list end
		if wrap and #list > 0 then
			moving[1].stacks[wrap] = list
			target.block.stacks[target.name] = moving
		else
			for i = #moving, 1, -1 do table.insert(list, 1, moving[i]) end
		end
	elseif target.kind == "input" then
		local old = target.block.inputs[target.name]
		target.block.inputs[target.name] = moving[1]
		if type(old) == "table" and old.op then
			-- the reporter that was in the slot pops out beside the new one
			table.insert(self.data.scripts, { x = script.x + 40, y = script.y + 40, blocks = { old } })
		end
	end
	self:changed()
	return true
end

-- Index of the script that holds `block` anywhere inside it (stack, C-slot or nested in an input), plus the
-- script's top-level block list.
local function contains(blocks, target)
  for _, b in ipairs(blocks) do
    if b == target then return true end
    for _, v in pairs(b.inputs) do
      if type(v) == "table" and v.op and contains({ v }, target) then return true end
    end
    for _, sub in pairs(b.stacks) do
      if contains(sub, target) then return true end
    end
  end
  return false
end

function Program:scriptOf(block)
  for i, s in ipairs(self.data.scripts) do
    if contains(s.blocks, block) then return i, s end
  end
end

-- Sets a literal in an input slot. Views re-render from the change.
-- onSet(block, name, old, new), if the host set one, runs after the value is stored and before views update, so the
-- host can keep things that depend on the value in step (custom block renames, stop-block shape).
function Program:setInput(block, name, value)
	local old = block.inputs[name]
	block.inputs[name] = value
	if self.onSet then self.onSet(block, name, old, value) end
	self:changed()
end

function Program:moveScript(i, x, y)
  local s = self.data.scripts[i]
  s.x, s.y = x, y
  self:changed()
end

function Program:removeScript(i)
  table.remove(self.data.scripts, i)
  self:changed()
end

return Program
