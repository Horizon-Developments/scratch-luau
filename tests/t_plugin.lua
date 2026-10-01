-- Plugin object tests. Plain Lua 5.3+ (run from the project root: lua tests/t_plugin.lua).
-- Plugin has no requires, so it is loaded with dofile; Registry is pure Lua too.
local Plugin = dofile("src/Plugin/init.lua")
local Registry = dofile("src/Lang/Core/Registry.lua")
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) end
end
local function throws(name, fn)
	if pcall(fn) then fails = fails + 1; print("FAIL", name, "expected an error") end
end

-- GetData
local p = Plugin.new({ Name = "Demo", Description = "d", Version = "1.2" })
local d = p:GetData()
eq("name", d.Name, "Demo"); eq("desc", d.Description, "d"); eq("extra kept", d.Version, "1.2")
eq("no cats", #d.Categories, 0); eq("no blocks", #d.Blocks, 0)
d.Name = "changed"
eq("GetData copy", p:GetData().Name, "Demo")
local q = Plugin.new()
eq("default name", q:GetData().Name, "Unnamed plugin"); eq("default desc", q:GetData().Description, "")
eq("methods via __index", getmetatable(p).__index, Plugin)

-- CreateCategory
local cat = p:CreateCategory("Demo", { name = "Demo cat", color = { 1, 2, 3 } })
eq("cat id", cat.id, "Demo"); eq("cat name", cat.name, "Demo cat"); eq("cat color", cat.color[3], 3)
eq("cat again = same", p:CreateCategory("Demo"), cat)
eq("cat default name", p:CreateCategory("Other").name, "Other")
throws("cat bad id", function() p:CreateCategory("") end)

-- CreateBlock: defaults and editing
local b = p:CreateBlock("demo_hi", { label = "hi {WHO}", inputs = { WHO = { type = "string", default = "you" } },
	run = function() end })
eq("block id", b.id, "demo_hi"); eq("shape default", b.shape, "stack")
eq("category default = last created", b.category, "Other")
b:SetCategory("Demo"):SetLabel("hello {WHO}"):SetShape("cap")
eq("edit label", b.label, "hello {WHO}"); eq("edit shape", b.shape, "cap"); eq("edit cat", b.category, "Demo")
b.label = "hey {WHO}"; eq("plain field edit", b.label, "hey {WHO}")
b:SetInput("N", { type = "number", default = 1 }); eq("SetInput", b.inputs.N.default, 1)
b:RemoveInput("N"); eq("RemoveInput", b.inputs.N, nil)
local def = b:ToDef(); eq("ToDef plain", getmetatable(def), nil); eq("ToDef field", def.id, "demo_hi")
eq("methods not stored as fields", rawget(b, "SetLabel"), nil)
eq("same object in GetData", p:GetData().Blocks[1], b)
throws("dup block", function() p:CreateBlock("demo_hi") end)
throws("bad shape", function() p:CreateBlock("x", { shape = "round" }) end)
throws("no category", function() Plugin.new():CreateBlock("y") end)
throws("bad id", function() p:CreateBlock(5) end)

-- Registry accepts what the plugin stores
local r = Registry.new()
for _, c in ipairs(p:GetData().Categories) do r:defineCategory(c.id, c) end
local ok, err = pcall(function() r:defineBlock(b) end)
eq("defineBlock accepts Block", ok, true)
if not ok then print(err) end
eq("registered", r:get("demo_hi") == b, true)
local inst = r:createBlock("demo_hi")
eq("createBlock default", inst.inputs.WHO, "you")
-- bad label input surfaces at registry time
local bad = p:CreateBlock("demo_bad", { category = "Demo", label = "x {NOPE}", run = function() end })
eq("bad label rejected by registry", pcall(function() r:defineBlock(bad) end), false)

print(fails == 0 and "t_plugin: ok" or ("t_plugin: " .. fails .. " failed"))
os.exit(fails == 0 and 0 or 1)
