-- BlockScript plugin object. Pure Lua (no Roblox APIs, no requires) so it stays loadstring-loadable
-- and testable under plain Lua:
--   local Plugin = loadstring(game:HttpGetAsync("<URL>", true))()
--   local p = Plugin.new({ Name = "Mine", Description = "..." })
--   local cat = p:CreateCategory("Mine", { name = "Mine", color = { 90, 90, 200 } })
--   p:CreateBlock("mine_hello", { shape = "stack", label = "hello {WHO}",
--       inputs = { WHO = { type = "string", default = "world" } },
--       run = function(ctx, a) ctx:say("hello " .. tostring(a.WHO), "say") end })
--   Scratch:LoadPlugin(p)   -- step 2
-- Categories and blocks are stored in the same shape Registry:defineCategory / Registry:defineBlock take,
-- so LoadPlugin can hand them over unchanged.
local Plugin = {}
Plugin.__index = Plugin

local SHAPES = { hat = true, stack = true, cap = true, c = true, reporter = true, boolean = true }

-- Block: an ordinary Registry block def (id, category, shape, label, inputs, stacks, hat, run, ...) with edit
-- helpers on its metatable, so every def field is a plain, editable key and pairs() shows only def fields.
local Block = {}
Block.__index = Block

function Block:SetLabel(label) self.label = label; return self end
function Block:SetShape(shape)
	assert(SHAPES[shape], "bad shape: " .. tostring(shape))
	self.shape = shape
	return self
end
function Block:SetCategory(id) self.category = id; return self end
function Block:SetRun(fn)
	assert(type(fn) == "function", "run must be a function")
	self.run = fn
	return self
end
function Block:SetInput(name, spec) self.inputs[name] = spec; return self end
function Block:RemoveInput(name) self.inputs[name] = nil; return self end
-- C-shaped blocks: name of each inner stack, in display order (Registry def.stacks).
function Block:SetStacks(names) self.stacks = names; return self end
function Block:SetHat(hat) self.hat = hat; return self end
function Block:Set(field, value) self[field] = value; return self end

-- Plain copy of the def (no methods), the form Registry:defineBlock takes.
function Block:ToDef()
	local out = {}
	for k, v in pairs(self) do out[k] = v end
	return out
end

-- data: { Name, Description, ...extra }. Every field is kept and comes back from GetData.
function Plugin.new(data)
	data = data or {}
	assert(type(data) == "table", "Plugin.new expects a table")
	local self = setmetatable({}, Plugin)
	self._data = {}
	for k, v in pairs(data) do self._data[k] = v end
	if self._data.Name == nil then self._data.Name = "Unnamed plugin" end
	if self._data.Description == nil then self._data.Description = "" end
	self._categories, self._categoryById = {}, {}
	self._blocks, self._blockById = {}, {}
	return self
end

-- Category, same fields as Registry:defineCategory(id, { name, color = {r,g,b} }).
-- Creating an id again returns the existing category (edit it in place).
function Plugin:CreateCategory(id, def)
	assert(type(id) == "string" and id ~= "", "category id must be a non-empty string")
	local cat = self._categoryById[id]
	if cat then return cat end
	def = def or {}
	cat = { id = id, name = def.name or id, color = def.color or { 150, 150, 150 } }
	self._categoryById[id] = cat
	table.insert(self._categories, cat)
	return cat
end

-- Block, same fields as a Registry:defineBlock def. `fields` may hold any of them; id is the first argument.
-- Defaults: shape "stack", category = the category created last, label = id, empty inputs/stacks.
-- `run` and any input a label uses are checked by Registry:defineBlock when the plugin loads.
-- Returns the Block: edit its fields (or use the Set* helpers) any time before LoadPlugin.
function Plugin:CreateBlock(id, fields)
	assert(type(id) == "string" and id ~= "", "block id must be a non-empty string")
	assert(not self._blockById[id], "duplicate block id in plugin: " .. id)
	fields = fields or {}
	assert(type(fields) == "table", "CreateBlock fields must be a table")
	local block = setmetatable({}, Block)
	for k, v in pairs(fields) do block[k] = v end
	block.id = id
	block.shape = block.shape or "stack"
	assert(SHAPES[block.shape], "bad shape for " .. id .. ": " .. tostring(block.shape))
	block.category = block.category or (self._categories[#self._categories] and self._categories[#self._categories].id)
	assert(block.category, "block " .. id .. " has no category: pass fields.category or call CreateCategory first")
	block.label = block.label or id
	block.inputs = block.inputs or {}
	block.stacks = block.stacks or {}
	self._blockById[id] = block
	table.insert(self._blocks, block)
	return block
end

-- { Name, Description, ...extra } plus Categories and Blocks (arrays, creation order; the live objects, so
-- edits show up). Returns a new table each call; changing the returned table does not change the plugin,
-- except for the Categories/Blocks entries themselves.
function Plugin:GetData()
	local out = {}
	for k, v in pairs(self._data) do out[k] = v end
	out.Categories = table.move(self._categories, 1, #self._categories, 1, {})
	out.Blocks = table.move(self._blocks, 1, #self._blocks, 1, {})
	return out
end

Plugin.Block = Block

return Plugin
