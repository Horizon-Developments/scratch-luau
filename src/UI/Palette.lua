-- Left pane: category tabs (from registry.categoryOrder) + block list for the selected category.
-- Click a block to add a copy to the workspace (onSpawn(op)). Drag-out arrives in step 3.
local Theme = require(script.Parent.Theme)
local BlockView = require(script.Parent.BlockView)
local Drag = require(script.Parent.Drag)

local Palette = {}
Palette.__index = Palette

local function corner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = Theme.radius
	c.Parent = parent
end

function Palette.new(parent, registry, onSpawn, onHover, onHoverEnd)
	local self = setmetatable({ registry = registry, onSpawn = onSpawn, onHover = onHover, onHoverEnd = onHoverEnd, tabs = {}, selected = nil }, Palette)

	local root = Instance.new("Frame")
	root.Name = "Palette"
	root.BackgroundColor3 = Theme.panel
	root.BorderSizePixel = 0
	root.Size = UDim2.new(0, Theme.paletteWidth, 1, 0)
	root.Parent = parent
  self.root, self.parent = root, parent

	local tabCol = Instance.new("ScrollingFrame")
	tabCol.Name = "Tabs"
	tabCol.BackgroundTransparency = 1
	tabCol.BorderSizePixel = 0
	tabCol.Size = UDim2.new(0, Theme.tabWidth, 1, 0)
	tabCol.CanvasSize = UDim2.new(0, 0, 0, 0)
	tabCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabCol.ScrollBarThickness = 0
	tabCol.Parent = root
	self.tabCol = tabCol
	local tl = Instance.new("UIListLayout")
	tl.Padding = UDim.new(0, 4)
	tl.SortOrder = Enum.SortOrder.LayoutOrder
	tl.Parent = tabCol
	local tp = Instance.new("UIPadding")
	tp.PaddingTop, tp.PaddingLeft, tp.PaddingRight = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 4)
	tp.Parent = tabCol

	local list = Instance.new("ScrollingFrame")
	list.Name = "Blocks"
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Position = UDim2.new(0, Theme.tabWidth, 0, 0)
	list.Size = UDim2.new(1, -Theme.tabWidth, 1, 0)
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.XY
	list.ScrollingDirection = Enum.ScrollingDirection.XY
	list.ScrollBarThickness = 6
	list.ScrollBarImageColor3 = Theme.textDim
	list.Parent = root
	local ll = Instance.new("UIListLayout")
	ll.Padding = UDim.new(0, 4)
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Parent = list
	local lp = Instance.new("UIPadding")
	lp.PaddingTop, lp.PaddingLeft, lp.PaddingRight, lp.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8)
	lp.Parent = list
	self.list = list

	for i, id in ipairs(registry.categoryOrder) do
		self:_addTab(tabCol, id, i)
	end
	if registry.categoryOrder[1] then self:select(registry.categoryOrder[1]) end
	return self
end

function Palette:_addTab(parent, id, order)
	local cat = self.registry.categories[id]
	local tab = Instance.new("TextButton")
	tab.Name = "Tab_" .. id
	tab.AutoButtonColor = false
	tab.BackgroundColor3 = Theme.panel
	tab.BorderSizePixel = 0
	tab.Size = UDim2.new(1, 0, 0, Theme.tabHeight)
	tab.LayoutOrder = order
	tab.Font = Theme.font
	tab.TextSize = Theme.textSize
	tab.TextColor3 = Theme.text
	tab.TextXAlignment = Enum.TextXAlignment.Left
	tab.Text = cat.name
	tab.Parent = parent
	corner(tab)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 14)
	pad.Parent = tab
	-- Category key: the tab's identity color. Functional (matches the blocks it lists), not decoration.
	local key = Instance.new("Frame")
	key.Name = "CategoryKey"
	key.BackgroundColor3 = Theme.categoryColor(cat)
	key.BorderSizePixel = 0
	key.Size = UDim2.new(0, 4, 1, -12)
	key.Position = UDim2.new(0, -8, 0, 6)
	key.Parent = tab
	tab.Activated:Connect(function() self:select(id) end)
	self.tabs[id] = tab
end

function Palette:select(id)
	self.selected = id
	for tid, tab in pairs(self.tabs) do
		tab.BackgroundColor3 = (tid == id) and Theme.accent or Theme.panel
	end
	for _, child in ipairs(self.list:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end
	self.list.CanvasPosition = Vector2.new(0, 0)

	local view = BlockView.new(self.registry)
	for i, def in ipairs(self.registry:listByCategory(id)) do
		-- holder gives a 4px margin around each block so the hit target is >= 40px tall
		local holder = Instance.new("Frame")
		holder.Name = "Item_" .. def.id
		holder.BackgroundTransparency = 1
		holder.AutomaticSize = Enum.AutomaticSize.XY
		holder.Size = UDim2.new(0, 0, 0, 0)
		holder.LayoutOrder = i
		holder.Parent = self.list
		local pad = Instance.new("UIPadding")
		pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)
		pad.Parent = holder
		local blockFrame = view:build(self.registry:createBlock(def.id), holder)
		-- Hit button is a sibling of the block (the block's own UIListLayout would otherwise lay it out);
		-- its size follows the block's rendered size.
		local hit = Instance.new("TextButton")
		hit.Name = "Hit"
		hit.BackgroundTransparency = 1
		hit.Text = ""
		hit.ZIndex = 10
		hit.Parent = holder
    local function fit() hit.Size = UDim2.fromOffset(blockFrame.AbsoluteSize.X / Theme.scale, blockFrame.AbsoluteSize.Y / Theme.scale) end
    blockFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
    fit()
    hit.InputBegan:Connect(function(input)
      local t = input.UserInputType
      if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
        self:_drag(input, def.id, blockFrame)
      end
    end)
	end
end

-- Rebuilds the visible block list (registry changed, e.g. a custom block was defined).
function Palette:refresh()
  -- categories added after construction (plugins) get their tab here
  for i, id in ipairs(self.registry.categoryOrder) do
    if not self.tabs[id] then self:_addTab(self.tabCol, id, i) end
  end
  if self.selected then self:select(self.selected)
  elseif self.registry.categoryOrder[1] then self:select(self.registry.categoryOrder[1]) end
end

function Palette:_ghost(op)
  local holder = Instance.new("Frame")
  holder.Name = "DragGhost"
  holder.BackgroundTransparency = 1
  holder.AutomaticSize = Enum.AutomaticSize.XY
  holder.Size = UDim2.new(0, 0, 0, 0)
  holder.ZIndex = 100
  holder.Parent = self.parent
  local block = BlockView.new(self.registry):build(self.registry:createBlock(op), holder)
  -- elevation = "being held" (DESIGN.md: the only shadow)
  local shadow = Instance.new("Frame")
  shadow.BackgroundColor3 = Color3.new(0, 0, 0)
  shadow.BackgroundTransparency = 0.6
  shadow.BorderSizePixel = 0
  shadow.Position = UDim2.fromOffset(3, 4)
  shadow.ZIndex = 0
  shadow.Parent = holder
  corner(shadow)
  local function fit() shadow.Size = UDim2.fromOffset(block.AbsoluteSize.X / Theme.scale, block.AbsoluteSize.Y / Theme.scale) end
  block:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
  fit()
  return holder, block
end

-- Tap = add near top-left. Drag out = drop where released. Touch drags must start horizontal so vertical still scrolls the list.
function Palette:_drag(input, op, source)
  local p0 = Vector2.new(input.Position.X, input.Position.Y)
  local grab = p0 - source.AbsolutePosition
  local touch = input.UserInputType == Enum.UserInputType.Touch
  local ghost, ghostBlock, dead
  Drag.track(input, function(p)
    if not ghost then
      local d = p - p0
      if dead or d.Magnitude < 8 then return end
      if touch and math.abs(d.Y) > math.abs(d.X) then
        dead = true
        return
      end
      self.list.ScrollingEnabled = false
      ghost, ghostBlock = self:_ghost(op)
    end
    ghost.Position = UDim2.fromOffset((p.X - grab.X - self.parent.AbsolutePosition.X) / Theme.scale, (p.Y - grab.Y - self.parent.AbsolutePosition.Y) / Theme.scale)
    if self.onHover then
      if p.X > self.root.AbsolutePosition.X + self.root.AbsoluteSize.X then self.onHover(op, ghostBlock)
      elseif self.onHoverEnd then self.onHoverEnd() end
    end
  end, function(p)
    self.list.ScrollingEnabled = true
    local size = ghostBlock and ghostBlock.AbsoluteSize
    if ghost then ghost:Destroy() end
    if self.onHoverEnd then self.onHoverEnd() end
    if dead then return end
    if not ghost or p.X > self.root.AbsolutePosition.X + self.root.AbsoluteSize.X then
      self.onSpawn(op, ghost and p - grab, size)
    end
  end)
end

return Palette
