-- Minimal fake of the Roblox UI API, enough to run UI/BlockView and UI/Shapes under plain Lua and inspect the result.
local M = {}

local function vec(x, y) return setmetatable({ X = x, Y = y, x = x, y = y }, { __add = function(a, b) return vec(a.X + b.X, a.Y + b.Y) end,
	__sub = function(a, b) return vec(a.X - b.X, a.Y - b.Y) end }) end
Vector2 = { new = vec }
UDim = { new = function(s, o) return { Scale = s, Offset = o } end }
UDim2 = {
	new = function(xs, xo, ys, yo) return { X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } } end,
	fromOffset = function(x, y) return { X = { Scale = 0, Offset = x }, Y = { Scale = 0, Offset = y } } end,
	fromScale = function(x, y) return { X = { Scale = x, Offset = 0 }, Y = { Scale = y, Offset = 0 } } end,
}
Color3 = {
	new = function(r, g, b) return { R = r, G = g, B = b } end,
	fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255 } end,
}
Enum = setmetatable({}, { __index = function(_, k)
	return setmetatable({}, { __index = function(_, v) return k .. "." .. v end })
end })

local Signal = {}
Signal.__index = Signal
function Signal.new() return setmetatable({ fns = {} }, Signal) end
function Signal:Connect(fn) table.insert(self.fns, fn) return { Disconnect = function() end } end
function Signal:Fire() for _, f in ipairs(self.fns) do f() end end

local Inst = {}
function Inst.new(class)
	local o = { ClassName = class, _children = {}, _attrs = {}, _sig = {}, _props = { AbsoluteSize = vec(0, 0), AbsolutePosition = vec(0, 0) } }
	return setmetatable(o, { __index = function(t, k)
		local v = Inst[k]
		if v ~= nil then return v end
		return t._props[k]
	end, __newindex = function(t, k, v)
		if k == "Parent" then
			local old = t._props.Parent
			if old then for i, c in ipairs(old._children) do if c == t then table.remove(old._children, i) break end end end
			t._props.Parent = v
			if v then table.insert(v._children, t) end
			return
		end
		t._props[k] = v
		if t._sig[k] then t._sig[k]:Fire() end
	end })
end
function Inst:GetChildren() return { table.unpack(self._children) } end
function Inst:GetDescendants()
	local out = {}
	local function walk(n) for _, c in ipairs(n._children) do out[#out + 1] = c; walk(c) end end
	walk(self)
	return out
end
function Inst:FindFirstChild(name) for _, c in ipairs(self._children) do if c.Name == name then return c end end end
function Inst:FindFirstChildOfClass(cls) for _, c in ipairs(self._children) do if c.ClassName == cls then return c end end end
function Inst:IsA(cls) return self.ClassName == cls or (cls == "GuiObject" and self.ClassName ~= "UICorner") end
function Inst:GetPropertyChangedSignal(p) self._sig[p] = self._sig[p] or Signal.new() return self._sig[p] end
function Inst:GetAttributeChangedSignal(p) self._sig["attr_" .. p] = self._sig["attr_" .. p] or Signal.new() return self._sig["attr_" .. p] end
function Inst:GetAttribute(k) return self._attrs[k] end
function Inst:SetAttribute(k, v) self._attrs[k] = v if self._sig["attr_" .. k] then self._sig["attr_" .. k]:Fire() end end
function Inst:Destroy() self.Parent = nil end
Instance = Inst

-- walks a built tree
function M.find(root, pred)
	local out = {}
	local function walk(n) if pred(n) then out[#out + 1] = n end for _, c in ipairs(n._children) do walk(c) end end
	walk(root)
	return out
end

-- loads src/UI modules with a fake script tree
function M.loader(dir, listdir)
	local cache, tree = {}, { Parent = nil }
	for _, f in ipairs(listdir(dir)) do
		local name = f:match("^(.-)%.lua$")
		if name then tree[name] = { __file = dir .. "/" .. f, Parent = tree } end
	end
	local function load_(n)
		if cache[n.__file] then return cache[n.__file] end
		local src = assert(io.open(n.__file)):read("a")
		local env = setmetatable({ script = n, require = load_ }, { __index = _G })
		local v = assert(load(src, "@" .. n.__file, "t", env))()
		cache[n.__file] = v
		return v
	end
	return tree, load_
end
return M
