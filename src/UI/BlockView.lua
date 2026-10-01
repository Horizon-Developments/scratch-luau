-- Renders one block instance (model table) into Roblox Instances using its Registry definition.
-- Static render only (step 2). Pure function of (registry, block); no state kept here.
-- Views are registered in `map[frame] = block` when a map is passed, so later steps can hit-test.
--
--   local view = BlockView.new(registry, map)
--   local frame = view:build(block, parent)          -- single block (nested inputs included)
--   local frame = view:buildStack(blocks, parent)    -- vertical stack of blocks
local Theme = require(script.Parent.Theme)
local Shapes = require(script.Parent.Shapes)
local Assets = require(script.Parent.Assets)

local BlockView = {}
BlockView.__index = BlockView

-- targets (optional) = { inputs = {}, slots = {}, fields = {} }: filled with drop targets for snapping.
--   targets.fields[frame] = { block, name }   editable literal field (tap to edit)
--   targets.inputs[frame] = { block, name }   input slot (field, empty boolean slot, or the reporter sitting in it)
--   targets.slots[frame]  = { block, name }   C-slot (substack) frame
function BlockView.new(registry, map, targets)
	return setmetatable({ registry = registry, map = map, targets = targets }, BlockView)
end

function BlockView:_target(frame, block, name)
	if self.targets then self.targets.inputs[frame] = { block = block, name = name } end
end

-- Editable literal fields only (not nested reporters, not empty boolean slots): the Editor opens on these.
function BlockView:_field(frame, block, name)
	if self.targets and self.targets.fields then self.targets.fields[frame] = { block = block, name = name } end
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Parent = parent
	return c
end

local function padding(parent, l, r, t, b)
	local p = Instance.new("UIPadding")
	p.PaddingLeft, p.PaddingRight = UDim.new(0, l), UDim.new(0, r)
	p.PaddingTop, p.PaddingBottom = UDim.new(0, t), UDim.new(0, b)
	p.Parent = parent
end

local function listLayout(parent, dir, gap, valign)
	local l = Instance.new("UIListLayout")
	l.FillDirection = dir
	l.Padding = UDim.new(0, gap)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.VerticalAlignment = valign or Enum.VerticalAlignment.Top
	l.Parent = parent
	return l
end

local function frame(parent, name, color)
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.AutomaticSize = Enum.AutomaticSize.XY
	f.Size = UDim2.new(0, 0, 0, 0)
	f.Parent = parent
	return f
end

local function label(parent, text, color, order)
	local t = Instance.new("TextLabel")
	t.Name = "Text"
	t.BackgroundTransparency = 1
	t.AutomaticSize = Enum.AutomaticSize.XY
	t.Size = UDim2.new(0, 0, 0, 24)
	t.Font = Theme.blockFont
	t.TextSize = Theme.textSize
	t.TextColor3 = color
	t.Text = text
	t.LayoutOrder = order
	t.Parent = parent
	return t
end

-- A literal / dropdown value drawn as a round field. Free-text fields are light with dark text; dropdown fields
-- (options / variable / list) are a darker shade of the block with light text, so the fill tells which kind of edit a
-- tap opens (Scratch does the same).
local function field(parent, value, order, dropdownColor)
	local fill = dropdownColor and Theme.dropdown(dropdownColor) or Theme.field
	local f = frame(parent, "Field", fill)
	f.LayoutOrder = order
	f.Size = UDim2.new(0, 0, 0, 24)
	f.AutomaticSize = Enum.AutomaticSize.X
	corner(f, UDim.new(0.5, 0))
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.AutomaticSize = Enum.AutomaticSize.X
	t.Size = UDim2.new(0, 0, 1, 0)
	t.Font = Theme.blockFont
	t.TextSize = Theme.textSize
	t.TextColor3 = dropdownColor and Theme.textOn(fill) or Theme.fieldText
	t.Text = tostring(value == nil and "" or value)
	t.Parent = f
	padding(t, 10, 10, 0, 0)
	local minw = Instance.new("UISizeConstraint")
	minw.MinSize = Vector2.new(28, 24)
	minw.Parent = f
	return f
end

-- Empty boolean slot: a hexagonal recess, a darker shade of the block it sits in.
local function emptySlot(parent, order, blockColor)
	local f = Instance.new("Frame")
	f.Name = "EmptySlot"
	f.BackgroundTransparency = 1
	f.BorderSizePixel = 0
	f.LayoutOrder = order
	f.Size = UDim2.new(0, 40, 0, 24)
	f.Parent = parent
	Shapes.hexagon(f, Theme.recess(blockColor), nil, 1)
	return f
end

function BlockView:_row(block, def, color, parent, shape)
	local row = Instance.new("Frame")
	row.Name = "Row"
	row.BackgroundTransparency = 1
	row.AutomaticSize = Enum.AutomaticSize.XY
	row.Size = UDim2.new(0, 0, 0, Theme.rowHeight)
	row.Parent = parent
	listLayout(row, Enum.FillDirection.Horizontal, Theme.gap, Enum.VerticalAlignment.Center)
	-- a boolean's pointed ends take half its height on each side; the 4px top and bottom inset lets a block in a slot
	-- sit inside the row with a margin, and makes the row grow by one step per nesting level
	local side = shape == "boolean" and Theme.pad + 14 or Theme.pad
	padding(row, side, side, 4, 4)
	local textColor = Theme.textOn(color)

	for i, seg in ipairs(def.segments) do
		if seg.icon then
			Assets.icon(row, seg.icon, Theme.iconSize, i)
		elseif seg.text then
			-- trim so the layout gap controls spacing
			local text = seg.text:gsub("^%s+", ""):gsub("%s+$", "")
			if text ~= "" then label(row, text, textColor, i) end
		else
			local spec = def.inputs[seg.input]
			local v = block.inputs[seg.input]
			if type(v) == "table" and v.op then
				local child = self:build(v, row)
				child.LayoutOrder = i
				self:_target(child, block, seg.input)
			elseif spec.type == "boolean" and v == nil then
				self:_target(emptySlot(row, i, color), block, seg.input)
			else
				local isDropdown = spec.options ~= nil or spec.type == "variable" or spec.type == "list" or spec.type == "param"
				local f = field(row, v, i, isDropdown and color or nil)
				self:_target(f, block, seg.input)
				self:_field(f, block, seg.input)
			end
		end
	end
	return row
end

function BlockView:build(block, parent)
	local def = assert(self.registry:get(block.op), "unknown block: " .. tostring(block.op))
	local color = Theme.categoryColor(self.registry.categories[def.category])
	local shape = self.registry:shapeOf(block)

	local root = frame(parent, "Block_" .. block.op, color)
	-- `body` = where rows go: root itself, or an inner frame for shapes drawn behind their content (boolean)
	local body = Shapes.surface(root, shape, color, Theme.edge(color), { bowler = def.bowler })
	listLayout(body, Enum.FillDirection.Vertical, 0)
	if self.map then self.map[root] = block end

	local head = self:_row(block, def, color, body, shape)
	head.LayoutOrder = 1

	if #def.stacks > 0 then
		for idx, name in ipairs(def.stacks) do
			if idx > 1 then
				-- named divider row for additional slots, e.g. "else"
				local sep = Instance.new("Frame")
				sep.Name = "Divider_" .. name
				sep.BackgroundTransparency = 1
				sep.AutomaticSize = Enum.AutomaticSize.XY
				sep.Size = UDim2.new(0, 0, 0, Theme.rowHeight)
				sep.LayoutOrder = idx * 2
				sep.Parent = body
				padding(sep, Theme.pad, Theme.pad, 0, 0)
				local l = label(sep, string.lower(name), Theme.textOn(color), 1)
				l.Position = UDim2.new(0, 0, 0.5, -12)
			end
			local slot = Instance.new("Frame")
			slot.Name = "Slot_" .. name
			slot.BackgroundTransparency = 1
			slot.AutomaticSize = Enum.AutomaticSize.XY
			slot.Size = UDim2.new(0, 0, 0, Theme.cSlotMinHeight)
			slot.LayoutOrder = idx * 2 + 1
			slot.Parent = body
			if self.targets then self.targets.slots[slot] = { block = block, name = name } end
			padding(slot, Theme.cSlotIndent, 0, 0, 0)
			local inner = self:buildStack(block.stacks[name] or {}, slot)
			inner.LayoutOrder = 1
			local minh = Instance.new("UISizeConstraint")
			minh.MinSize = Vector2.new(60, Theme.cSlotMinHeight)
			minh.Parent = inner
		end
		local foot = Instance.new("Frame")
		foot.Name = "Footer"
		foot.BackgroundTransparency = 1
		foot.Size = UDim2.new(0, 0, 0, def.footerIcon and Theme.cFooterIcon or Theme.cFooter)
		foot.LayoutOrder = 1000
		foot.Parent = body
		if def.footerIcon then
			-- Scratch's loop arrow in the bottom arm; the arm grows so the icon has room
			local icon = Assets.icon(foot, def.footerIcon, Theme.iconSize)
			icon.Position = UDim2.new(0, Theme.pad, 0.5, -Theme.iconSize / 2)
		end
	end

	return root
end

-- Vertical stack: blocks touch so they read as one script.
function BlockView:buildStack(blocks, parent)
	local stack = Instance.new("Frame")
	stack.Name = "Stack"
	stack.BackgroundTransparency = 1
	stack.AutomaticSize = Enum.AutomaticSize.XY
	stack.Size = UDim2.new(0, 0, 0, 0)
	stack.Parent = parent
	listLayout(stack, Enum.FillDirection.Vertical, 0)
	for i, b in ipairs(blocks) do
		local v = self:build(b, stack)
		v.LayoutOrder = i
		-- earlier blocks draw above later ones: a block's connector tab pokes into the next block's notch
		v.ZIndex = #blocks - i + 1
	end
	return stack
end

return BlockView
