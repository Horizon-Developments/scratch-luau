-- Registers a Plugin object (src/Plugin/init.lua) into a Registry. Pure Lua (no Roblox APIs).
-- All or nothing: if any category/block is rejected, everything this call added is removed again.
local Plugins = {}

local function deepCopy(v, seen)
	if type(v) ~= "table" then return v end
	seen = seen or {}
	if seen[v] then return seen[v] end
	local out = {}
	seen[v] = out
	for k, x in pairs(v) do out[deepCopy(k, seen)] = deepCopy(x, seen) end
	return out
end

-- Returns nil on success, or an error string "<plugin name>: <reason>".
function Plugins.load(registry, plugin)
	local name = "plugin"
	local addedCats, addedIds = {}, {}
	local ok, err = pcall(function()
		assert(type(plugin) == "table" and type(plugin.GetData) == "function", "not a plugin (no GetData)")
		local data = plugin:GetData()
		assert(type(data) == "table", "GetData must return a table")
		assert(type(data.Name) == "string" and data.Name ~= "", "plugin needs a Name")
		name = data.Name
		registry.plugins = registry.plugins or {}
		assert(not registry.plugins[name], "plugin already loaded")
		-- categories first (blocks need them). An id the registry already has is reused as is, so a plugin
		-- can add blocks to e.g. Control without recolouring it.
		for _, c in ipairs(data.Categories or {}) do
			assert(type(c) == "table" and type(c.id) == "string", "category needs a string id")
			if not registry.categories[c.id] then
				registry:defineCategory(c.id, c)
				table.insert(addedCats, c.id)
			end
		end
		for _, b in ipairs(data.Blocks or {}) do
			assert(type(b) == "table" and type(b.id) == "string", "block needs a string id")
			assert(not registry.blocks[b.id], "block id already exists: " .. b.id)
			-- a deep copy, so editing the plugin's Block later cannot change the live definition
			local def = {}
			for k, v in pairs(b) do def[k] = deepCopy(v) end
			registry:defineBlock(def)
			addedIds[b.id] = true
		end
	end)
	if not ok then
		registry:removeBlocks(addedIds)
		for _, id in ipairs(addedCats) do registry:removeCategory(id) end
		-- drop a leading "file:line: " so the message reads the same on every Lua
		return name .. ": " .. (string.gsub(tostring(err), "^[^\n:]*:%d+: ", ""))
	end
	registry.plugins[name] = { categories = addedCats, blocks = addedIds }
	return nil
end

return Plugins
