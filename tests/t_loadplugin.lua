-- Plugin loading tests (Plugins.load / Registry additions). Run from project root: texlua tests/t_loadplugin.lua
local Plugin = dofile("src/Plugin/init.lua")
local Registry = dofile("src/Lang/Core/Registry.lua")
local Plugins = dofile("src/Lang/Core/Plugins.lua")
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) end
end
local function fresh()
	local r = Registry.new()
	r:defineCategory("Control", { name = "Control", color = { 220, 120, 40 } })
	r:defineBlock({ id = "control_wait", category = "Control", shape = "stack", label = "wait", run = function() end })
	return r
end

-- success
local r = fresh()
local p = Plugin.new({ Name = "Demo", Description = "d" })
p:CreateCategory("Demo", { name = "Demo", color = { 1, 2, 3 } })
local b = p:CreateBlock("demo_hi", { label = "hi {WHO}", inputs = { WHO = { type = "string", default = "you" } },
	run = function() end })
eq("load ok", Plugins.load(r, p), nil)
eq("category added", r.categories.Demo ~= nil, true)
eq("category order", r.categoryOrder[#r.categoryOrder], "Demo")
eq("block added", r:get("demo_hi") ~= nil, true)
eq("listed in category", #r:listByCategory("Demo"), 1)
eq("createBlock works", r:createBlock("demo_hi").inputs.WHO, "you")
-- live def is a copy
b.label = "changed {WHO}"; b.inputs.WHO.default = "me"
eq("copy: label", r:get("demo_hi").label, "hi {WHO}")
eq("copy: input default", r:get("demo_hi").inputs.WHO.default, "you")
eq("copy is not the Block", r:get("demo_hi") == b, false)
-- loaded twice
eq("twice rejected", Plugins.load(r, p), "Demo: plugin already loaded")

-- failure rolls back everything
local r2 = fresh()
local bad = Plugin.new({ Name = "Bad" })
bad:CreateCategory("BadCat")
bad:CreateBlock("bad_ok", { run = function() end })
bad:CreateBlock("bad_broken", { label = "x {NOPE}", run = function() end })
local e = Plugins.load(r2, bad)
eq("fail returns string", type(e), "string")
eq("fail names plugin", e:sub(1, 5), "Bad: ")
eq("rollback block", r2:get("bad_ok"), nil)
eq("rollback category", r2.categories.BadCat, nil)
eq("rollback order", #r2.categoryOrder, 1)
eq("rollback blockOrder", #r2.blockOrder, 1)
eq("not marked loaded", r2.plugins and r2.plugins.Bad, nil)
-- after fixing, loads
bad:CreateBlock("bad_fixed", { run = function() end })
bad._blocks[2].label = "x"   -- fix the broken one
eq("retry ok", Plugins.load(r2, bad), nil)

-- duplicate id with the registry
local r3 = fresh()
local dup = Plugin.new({ Name = "Dup" })
dup:CreateCategory("D")
dup:CreateBlock("control_wait", { run = function() end })
eq("dup id", Plugins.load(r3, dup), "Dup: block id already exists: control_wait")
eq("dup: no category left", r3.categories.D, nil)

-- reuse existing category, keep its colour
local r4 = fresh()
local ex = Plugin.new({ Name = "Ex" })
ex:CreateCategory("Control", { color = { 9, 9, 9 } })
ex:CreateBlock("ex_block", { category = "Control", run = function() end })
eq("ex ok", Plugins.load(r4, ex), nil)
eq("colour kept", r4.categories.Control.color[1], 220)
eq("block in Control", #r4:listByCategory("Control"), 2)
-- failure must not remove a pre-existing category
local ex2 = Plugin.new({ Name = "Ex2" })
ex2:CreateCategory("Control")
ex2:CreateBlock("ex2_bad", { category = "Control", label = "{Z}", run = function() end })
eq("ex2 fails", type(Plugins.load(r4, ex2)), "string")
eq("Control survives rollback", r4.categories.Control ~= nil, true)

-- not a plugin
eq("nil plugin", type(Plugins.load(fresh(), nil)), "string")
eq("table plugin", type(Plugins.load(fresh(), {})), "string")
eq("no name", type(Plugins.load(fresh(), { GetData = function() return {} end })), "string")
-- empty plugin is fine
eq("empty plugin", Plugins.load(fresh(), Plugin.new({ Name = "Empty" })), nil)

print(fails == 0 and "t_loadplugin: ok" or ("t_loadplugin: " .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
