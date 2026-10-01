-- Field editor. Opened by Workspace when a literal field is tapped (no drag).
--   text field   -> TextBox laid over the field, commits on focus lost / Enter
--   options      -> list of def.inputs[NAME].options
--   variable/list-> names already used in the program, plus "New name" (opens the text box)
--   param        -> the arguments of the custom block definition the reporter sits in (text box if it is in none)
-- All changes go through Program:setInput, which re-renders the views.
local Theme = require(script.Parent.Theme)

local Editor = {}
Editor.__index = Editor

local ITEM_H = 40 -- touch target
local MENU_W = 168
local MENU_MAX_H = 280

function Editor.new(parent, registry, program)
	return setmetatable({ parent = parent, registry = registry, program = program }, Editor)
end

local function corner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = Theme.radius
	c.Parent = parent
end

-- screen px -> coordinates inside the scaled root
function Editor:_rel(abs)
	return (abs - self.parent.AbsolutePosition) / Theme.scale
end

function Editor:close()
	if self.layer then
		self.layer:Destroy()
		self.layer = nil
	end
end

-- Full-screen invisible button under the editor UI: tapping anywhere else closes it.
function Editor:_backdrop()
	self:close()
	local b = Instance.new("TextButton")
	b.Name = "EditorBackdrop"
	b.BackgroundTransparency = 1
	b.Text = ""
	b.AutoButtonColor = false
	b.Size = UDim2.fromScale(1, 1)
	b.ZIndex = 250
	b.Parent = self.parent
	b.Activated:Connect(function() self:close() end)
	self.layer = b
	return b
end

function Editor:_commit(block, name, spec, text)
	local value = text
	if spec.type == "number" or spec.type == "any" then
		local n = tonumber(text)
		if n ~= nil then
			value = n
		end -- non-numeric text in a number slot stays text: the block errors when it runs (Luau does not turn it into 0)
	end
	self:close()
	self.program:setInput(block, name, value)
end

function Editor:_text(field, block, name, spec, initial)
	local layer = self:_backdrop()
	local pos, size = self:_rel(field.AbsolutePosition), field.AbsoluteSize / Theme.scale
	local box = Instance.new("TextBox")
	box.Name = "FieldBox"
	box.BackgroundColor3 = Theme.field
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Font = Theme.font
	box.TextSize = Theme.textSize
	box.TextColor3 = Theme.fieldText
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Text = tostring(initial == nil and "" or initial)
	box.Position = UDim2.fromOffset(pos.X, pos.Y)
	box.Size = UDim2.fromOffset(math.max(size.X, 72), math.max(size.Y, 24))
	box.ZIndex = 300
	box.Parent = layer
	corner(box)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = box
	-- accent outline = "this is the field being edited" (accent is reserved for selection)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.accent
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = box
	local done = false
	box.FocusLost:Connect(function()
		if done then return end
		done = true
		self:_commit(block, name, spec, box.Text)
	end)
	box:CaptureFocus()
end

-- Names of variables / lists already used somewhere in the program (kind = "variable" | "list").
function Editor:_names(kind, current)
	local seen, out = {}, {}
	local function add(v)
		if type(v) == "string" and v ~= "" and not seen[v] then
			seen[v] = true
			table.insert(out, v)
		end
	end
	local function walk(blocks)
		for _, b in ipairs(blocks) do
			local def = self.registry:get(b.op)
			if def then
				for iname, ispec in pairs(def.inputs) do
					local v = b.inputs[iname]
					if ispec.type == kind then add(v) end
					if type(v) == "table" and v.op then walk({ v }) end
				end
			end
			for _, sub in pairs(b.stacks) do walk(sub) end
		end
	end
	for _, s in ipairs(self.program:get().scripts) do walk(s.blocks) end
	add(current)
	table.sort(out, function(a, b) return string.lower(a) < string.lower(b) end)
	return out
end

-- Argument names of the define at the top of the script holding `block` (empty when there is none).
function Editor:_paramNames(block)
	local out = {}
	local _, script = self.program:scriptOf(block)
	local first = script and script.blocks[1]
	if first and first.op == "custom_define" and type(first.inputs.NAME) == "string" then
		for _, p in ipairs(self.registry.custom.parse(first.inputs.NAME).params) do table.insert(out, p.name) end
	end
	return out
end

function Editor:_menu(field, block, name, spec, items, current, allowNew)
	local layer = self:_backdrop()
	local rows = #items + (allowNew and 1 or 0)
	local h = math.min(rows * ITEM_H, MENU_MAX_H)
	local pos, size = self:_rel(field.AbsolutePosition), field.AbsoluteSize / Theme.scale
	local bounds = self.parent.AbsoluteSize / Theme.scale
	local x = math.clamp(pos.X, 4, math.max(4, bounds.X - MENU_W - 4))
	local y = pos.Y + size.Y + 2
	if y + h > bounds.Y - 4 then y = math.max(4, pos.Y - h - 2) end -- no room below: open above

	local menu = Instance.new("ScrollingFrame")
	menu.Name = "FieldMenu"
	menu.BackgroundColor3 = Theme.panel
	menu.BorderSizePixel = 0
	menu.Position = UDim2.fromOffset(x, y)
	menu.Size = UDim2.fromOffset(MENU_W, h)
	menu.CanvasSize = UDim2.new(0, 0, 0, 0)
	menu.AutomaticCanvasSize = Enum.AutomaticSize.Y
	menu.ScrollBarThickness = 4
	menu.ScrollBarImageColor3 = Theme.textDim
	menu.ZIndex = 300
	menu.Parent = layer
	corner(menu)
	-- 1px outline separates the menu from the same-colored workspace behind it (functional)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.textDim
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = menu
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = menu

	local function item(text, order, selected, onPick)
		local b = Instance.new("TextButton")
		b.Name = "Item"
		b.AutoButtonColor = false
		b.BackgroundColor3 = selected and Theme.accent or Theme.panel
		b.BackgroundTransparency = selected and 0 or 1
		b.BorderSizePixel = 0
		b.Size = UDim2.new(1, 0, 0, ITEM_H)
		b.LayoutOrder = order
		b.Font = Theme.font
		b.TextSize = Theme.textSize
		b.TextColor3 = Theme.text
		b.TextXAlignment = Enum.TextXAlignment.Left
		b.Text = text
		b.ZIndex = 301
		b.Parent = menu
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 12)
		pad.Parent = b
		b.Activated:Connect(onPick)
	end

	for i, v in ipairs(items) do
		item(tostring(v), i, tostring(v) == tostring(current), function()
			self:close()
			self.program:setInput(block, name, v)
		end)
	end
	if allowNew then
		item("New name", #items + 1, false, function()
			self:_text(field, block, name, spec, "")
		end)
	end
end

-- field = the field Frame, info = { block, name } from BlockView targets.fields
function Editor:open(field, info)
	local def = self.registry:get(info.block.op)
	local spec = def and def.inputs[info.name]
	if not spec then return end
	local current = info.block.inputs[info.name]
	if spec.options then
		self:_menu(field, info.block, info.name, spec, spec.options, current, false)
	elseif spec.type == "param" and #self:_paramNames(info.block) > 0 then
		self:_menu(field, info.block, info.name, spec, self:_paramNames(info.block), current, false)
	elseif spec.type == "variable" or spec.type == "list" then
		self:_menu(field, info.block, info.name, spec, self:_names(spec.type, current), current, true)
	else
		self:_text(field, info.block, info.name, spec, current)
	end
end

return Editor
