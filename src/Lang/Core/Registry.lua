-- Block/category registry. THE extension point: define a category + blocks, done.
-- Pure Lua (no Roblox APIs). Colors are {r,g,b} 0-255 tables.
--
-- Block definition fields:
--   id        string, unique          category  string, must exist
--   shape     hat|stack|cap|c|reporter|boolean
--   label     "repeat {TIMES} times"  ({NAME} = input slot, order = display order; {@name} = inline icon, see UI/Assets)
--   inputs    { NAME = { type="number|string|boolean|variable|list|param|any",
--                        default=<v>, options={...}, lazy=bool, reporters=bool } }
--             reporters: may a reporter block be dropped into this slot? Default: yes, except for dropdown-only
--             slots (type variable/list/param, or options), like Scratch's field dropdowns. Set true on an options
--             slot that Scratch makes a menu *input* (key pressed); false to lock a plain text slot (hat inputs).
--             A boolean slot only takes boolean blocks, whatever this says.
--             raw=true: the block receives the value as it is (no conversion to the slot type), e.g. Luau and / or.
--   stacks    { "SUBSTACK", ... }     (C-shaped blocks; rendered after the label)
--   hat       { event="run", filter=function(args, payload) -> bool }   (hat only)
--             once=true: a trigger while the script is still running is ignored (default: the script restarts).
--             persistent=true keeps a run alive until Stop (event hats: key). poll=function(args, interp) -> bool
--             makes an edge-triggered hat: checked every frame, its script starts when the value goes false -> true.
--   footerIcon  "loop" on a C block: icon drawn in the block's bottom arm (Scratch's loop arrow on repeat/forever).
--   bowler    true on a hat: drawn as Scratch's rounded "define" hat instead of the domed event hat.
--   output    "any" on a reporter: no type, so it also fits boolean slots (Scratch's null-output blocks: item of list).
--   shapeOf   function(block) -> shape   (optional) shape can depend on the block's inputs (stop: cap vs stack)
--   listed    false hides the block from listByCategory (palette); it still renders and runs. Default: shown.
--   run       function(ctx, args) -> nil | "STOP"   (stack/cap/c)
--             function(ctx, args) -> value          (reporter/boolean)
local Registry = {}
Registry.__index = Registry

local SHAPES = { hat = true, stack = true, cap = true, c = true, reporter = true, boolean = true }

local function parseLabel(label)
	local segs, pos = {}, 1
	while true do
		local s, e, name = string.find(label, "{(@?[%w_]+)}", pos)
		if not s then break end
		if s > pos then table.insert(segs, { text = string.sub(label, pos, s - 1) }) end
		if string.sub(name, 1, 1) == "@" then table.insert(segs, { icon = string.sub(name, 2) })
		else table.insert(segs, { input = name }) end
		pos = e + 1
	end
	if pos <= #label then table.insert(segs, { text = string.sub(label, pos) }) end
	return segs
end

function Registry.new()
	return setmetatable({ blocks = {}, blockOrder = {}, categories = {}, categoryOrder = {} }, Registry)
end

function Registry:defineCategory(id, def)
	assert(type(id) == "string", "category id must be a string")
	def = def or {}
	if not self.categories[id] then table.insert(self.categoryOrder, id) end
	self.categories[id] = { id = id, name = def.name or id, color = def.color or { 150, 150, 150 } }
end

function Registry:defineBlock(def)
	assert(type(def) == "table" and type(def.id) == "string", "block needs a string id")
	assert(not self.blocks[def.id], "duplicate block id: " .. def.id)
	assert(SHAPES[def.shape], "bad shape for " .. def.id)
	assert(self.categories[def.category], "unknown category for " .. def.id)
	def.inputs = def.inputs or {}
	def.stacks = def.stacks or {}
	def.label = def.label or def.id
	def.segments = parseLabel(def.label)
	if def.shape == "hat" then
		assert(def.hat and def.hat.event, "hat block needs hat.event: " .. def.id)
		def.run = def.run or function() end
	end
	assert(type(def.run) == "function", "block needs run(): " .. def.id)
	for _, seg in ipairs(def.segments) do
		if seg.input then assert(def.inputs[seg.input], def.id .. ": label uses undeclared input " .. seg.input) end
	end
	self.blocks[def.id] = def
	table.insert(self.blockOrder, def.id)
	return def
end

-- Removes a block definition (runtime-made ones, e.g. custom calls nothing uses any more). `ids` = set { [id] = true }.
function Registry:removeBlocks(ids)
	local keep, n = {}, 0
	for _, id in ipairs(self.blockOrder) do
		if ids[id] then self.blocks[id] = nil; n = n + 1 else table.insert(keep, id) end
	end
	self.blockOrder = keep
	return n
end

-- Removes a category (plugin rollback). Blocks still pointing at it must be removed first.
function Registry:removeCategory(id)
	if not self.categories[id] then return false end
	self.categories[id] = nil
	local keep = {}
	for _, cid in ipairs(self.categoryOrder) do
		if cid ~= id then table.insert(keep, cid) end
	end
	self.categoryOrder = keep
	return true
end

function Registry:get(id) return self.blocks[id] end

-- Shape of a placed block (def.shape unless the def computes it from the block's inputs).
function Registry:shapeOf(block)
	local def = self.blocks[block.op]
	if def.shapeOf then return def.shapeOf(block) end
	return def.shape
end

-- May a block of `shape` sit in input `name` of `def`? `source` (the dragged block's definition) lets untyped
-- reporters (output = "any") into boolean slots.
function Registry:accepts(def, name, shape, source)
	local spec = def and def.inputs[name]
	if not spec then return false end
	if shape ~= "reporter" and shape ~= "boolean" then return false end
	local reporters = spec.reporters
	if reporters == nil then
		reporters = not (spec.options ~= nil or spec.type == "variable" or spec.type == "list" or spec.type == "param")
	end
	if not reporters then return false end
	if spec.type == "boolean" then return shape == "boolean" or (source ~= nil and source.output == "any") end
	return true
end

-- Name of the first C-slot of `block` when that slot is empty: the slot a dropped C-block wraps around the blocks
-- it lands on (Scratch's wrap behaviour). nil when the block has no slot or its first slot is already filled.
function Registry:wrapSlot(block)
	local def = block and self.blocks[block.op]
	local name = def and def.stacks[1]
	if not name then return nil end
	local list = block.stacks and block.stacks[name]
	if list and #list > 0 then return nil end
	return name
end

function Registry:listByCategory(categoryId)
	local out = {}
	for _, id in ipairs(self.blockOrder) do
		if self.blocks[id].category == categoryId and self.blocks[id].listed ~= false then table.insert(out, self.blocks[id]) end
	end
	return out
end

-- New block instance: { op, inputs = {NAME = literal|block}, stacks = {NAME = {block,...}} }
function Registry:createBlock(op)
	local def = assert(self.blocks[op], "unknown block: " .. tostring(op))
	local blk = { op = op, inputs = {}, stacks = {} }
	for name, spec in pairs(def.inputs) do blk.inputs[name] = spec.default end
	for _, name in ipairs(def.stacks) do blk.stacks[name] = {} end
	return blk
end

return Registry
