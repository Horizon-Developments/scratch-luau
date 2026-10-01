package.path = "tests/?.lua;" .. package.path
local M = require("ui_mock")
local H = require("harness")
local tree, load_ = M.loader("src/UI", function(d) local t = {} for f in string.gmatch(LISTDIR(d), "[^\n]+") do t[#t + 1] = f end return t end)
local Theme, Shapes, BlockView = load_(tree.Theme), load_(tree.Shapes), load_(tree.BlockView)
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end
local function near(name, got, want) eq(name, math.abs(got - want) < 1e-6, true) end

-- colors
local function contrast(a, b) local la, lb = Theme.luminance(a), Theme.luminance(b) if la < lb then la, lb = lb, la end return (la + 0.05) / (lb + 0.05) end
local reg = H.BS.newRegistry()
local worst = 99
for _, id in ipairs(reg.categoryOrder) do
	local c = Theme.categoryColor(reg.categories[id])
	local t = Theme.textOn(c)
	local r = contrast(c, t)
	worst = math.min(worst, r)
	print(string.format("     %-10s text %s  contrast %.1f", id, t.R > 0.5 and "white" or "dark ", r))
	local dd = Theme.dropdown(c)
	worst = math.min(worst, contrast(dd, Theme.textOn(dd)))
end
eq("every block text >= 4.5:1", worst >= 4.5, true)

-- every block in the registry builds, in a stack and alone
local view = BlockView.new(reg, {}, { inputs = {}, slots = {}, fields = {} })
local n = 0
for _, id in ipairs(reg.blockOrder) do
	local host = Instance.new("Frame")
	local ok, err = pcall(function() view:build(reg:createBlock(id), host) end)
	if not ok then fails = fails + 1; print("FAIL build", id, err) end
	n = n + 1
end
print("     built " .. n .. " block types")

-- structure per shape
local function built(op, setup)
	local host = Instance.new("Frame")
	local b = reg:createBlock(op)
	if setup then setup(b) end
	return BlockView.new(reg, {}, nil):build(b, host), host
end
local function named(root, name) return M.find(root, function(x) return x.Name == name end) end
local stack = built("out_print")
eq("stack: tab", #named(stack, "Tab"), 1)
eq("stack: notch", #named(stack, "Notch"), 1)
eq("stack: outline", stack:FindFirstChildOfClass("UIStroke") ~= nil, true)
local cap = built("control_stop")
eq("cap: no tab", #named(cap, "Tab"), 0)
eq("cap: notch", #named(cap, "Notch"), 1)
local forever = built("control_forever")
eq("forever: no tab (end block)", #named(forever, "Tab"), 0)
local hat = built("events_when_run")
eq("hat: dome", #named(hat, "Dome"), 1)
eq("hat: tab", #named(hat, "Tab"), 1)
eq("hat: no notch", #named(hat, "Notch"), 0)
local def = built("custom_define")
eq("bowler: no dome", #named(def, "Dome"), 0)
eq("bowler: rounded 14", def:FindFirstChildOfClass("UICorner").CornerRadius.Offset, 14)
local rep = built("op_add")
eq("reporter: pill", rep:FindFirstChildOfClass("UICorner").CornerRadius.Scale, 0.5)
eq("reporter: no tab/notch", #named(rep, "Tab") + #named(rep, "Notch"), 0)
local bool = built("op_eq")
eq("boolean: hexagon", #named(bool, "Hex"), 1)
eq("boolean: transparent root", bool.BackgroundTransparency, 1)
eq("boolean: content frame", #named(bool, "Content"), 1)
local row = named(bool, "Content")[1]
eq("boolean: rows live in content", #named(row, "Row"), 1)
local ifb = built("control_if")
eq("c block: slot", #named(ifb, "Slot_THEN"), 1)
eq("c block: tab", #named(ifb, "Tab"), 1)
eq("empty boolean slot is a hexagon", #named(ifb, "EmptySlot"), 1)
eq("empty slot hexagon", #named(named(ifb, "EmptySlot")[1], "Hex"), 1)

-- hexagon geometry: a 120 x 40 hexagon
Theme.scale = 1
local host = Instance.new("Frame")
local hex = Shapes.hexagon(host, Color3.new(1, 0, 0), Color3.new(0, 0, 0), 1)
hex.AbsoluteSize = Vector2.new(120, 40)
local e = hex:FindFirstChild("Edge")
near("hex: edge mid x", e:FindFirstChild("Mid").Position.X.Offset, 20)
near("hex: edge mid w", e:FindFirstChild("Mid").Size.X.Offset, 80)
near("hex: point square side", e:FindFirstChild("Left").Size.X.Offset, 40 / math.sqrt(2))
near("hex: left point center x", e:FindFirstChild("Left").Position.X.Offset, 20)
near("hex: right point center x", e:FindFirstChild("Right").Position.X.Offset, 100)
local f = hex:FindFirstChild("Fill")
near("hex: fill inset", f.Position.X.Offset, 1)
near("hex: fill w", f.Size.X.Offset, 118)
-- the UIScale the root runs at divides out
Theme.scale = 0.5
hex.AbsoluteSize = Vector2.new(60, 20)
near("hex: scaled mid w", hex:FindFirstChild("Edge"):FindFirstChild("Mid").Size.X.Offset, 80)
Theme.scale = 1

-- error marking on both families
Shapes.markError(stack, Theme.error, 3)
eq("error: stroke", stack:FindFirstChildOfClass("UIStroke").Thickness, 3)
hex.AbsoluteSize = Vector2.new(120, 40)
local holderBool = Instance.new("Frame"); hex.Parent = holderBool
Shapes.markError(holderBool, Theme.error, 3)
eq("error: hex inset", hex:GetAttribute("Inset"), 3)
near("error: hex fill follows", f.Position.X.Offset, 3)

-- a stack: earlier blocks sit above later ones
local sh = Instance.new("Frame")
local st = BlockView.new(reg, {}, nil):buildStack({ reg:createBlock("out_print"), reg:createBlock("out_print"), reg:createBlock("out_print") }, sh)
local z = {}
for _, c in ipairs(st._children) do if c.ClassName == "Frame" then z[#z + 1] = c.ZIndex end end
eq("stack z-order", table.concat(z, ","), "3,2,1")
print(fails == 0 and "shapes OK" or (fails .. " FAILED"))
