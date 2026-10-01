-- Center pane: pannable canvas that renders Program scripts. Model (Program) and views are separate:
-- the workspace rebuilds views from the model whenever the model reports a change.
local Players = game:GetService("Players")
local Theme = require(script.Parent.Theme)
local BlockView = require(script.Parent.BlockView)
local Shapes = require(script.Parent.Shapes)
local Drag = require(script.Parent.Drag)

local Workspace = {}
Workspace.__index = Workspace

function Workspace.new(parent, registry, program)
	local self = setmetatable({ registry = registry, program = program, blockOf = {} }, Workspace)

	local canvas = Instance.new("ScrollingFrame")
	canvas.Name = "Workspace"
	canvas.BackgroundColor3 = Theme.ground
	canvas.BorderSizePixel = 0
	-- sits between the toolbar (top) and the console (bottom)
	canvas.Size = UDim2.new(1, -Theme.paletteWidth, 1, -(Theme.toolbarHeight + Theme.consoleHeight))
	canvas.Position = UDim2.new(0, Theme.paletteWidth, 0, Theme.toolbarHeight)
	canvas.ScrollingDirection = Enum.ScrollingDirection.XY
	canvas.CanvasSize = UDim2.new(0, 0, 0, 0)
	canvas.AutomaticCanvasSize = Enum.AutomaticSize.XY
	canvas.ScrollBarThickness = 8
	canvas.ScrollBarImageColor3 = Theme.textDim
	canvas.Parent = parent
	self.canvas = canvas

	local layer = Instance.new("Frame")
	layer.Name = "Scripts"
	layer.BackgroundTransparency = 1
	layer.Size = UDim2.new(1, 0, 1, 0)
	layer.Parent = canvas
	self.layer = layer

	-- Snap preview: accent line (stack targets) or accent tint (input targets). Lives on the root so it is never clipped.
	local preview = Instance.new("Frame")
	preview.Name = "SnapPreview"
	preview.BackgroundColor3 = Theme.accent
	preview.BorderSizePixel = 0
	preview.Visible = false
	preview.ZIndex = 200
	preview.Parent = parent
	self.preview, self.targets = preview, { inputs = {}, slots = {}, fields = {} }

	self:_wirePan()
	program:onChanged(function() self:render() end)
	self:render()
	return self
end

function Workspace:_toCanvas(p)
  return (p - self.canvas.AbsolutePosition) / Theme.scale + self.canvas.CanvasPosition
end

-- Drags the block under the pointer (with everything below it if it is a stack block, or just the reporter
-- if it sits in an input slot). Returns false if no block is there.
function Workspace:_grab(input, frame, field)
  -- No coordinate hit-test: the frame (and literal field) come from the frames' own InputBegan events
  -- (see _wireHits), so the GUI inset, other ScreenGuis on top and gethui() containers cannot throw it off.
  if not frame or not self.blockOf[frame] then return false end
  local p0 = Vector2.new(input.Position.X, input.Position.Y)
  local block = self.blockOf[frame]
  local index, holder, x0, y0
  self.busy = true
  self.canvas.ScrollingEnabled = false
  Drag.track(input, function(p)
    if not holder then
      if (p - p0).Magnitude < 6 then return end
      local at = self:_toCanvas(frame.AbsolutePosition)
      if self.program:find(block) then
        index = self.program:detach(block, at.X, at.Y - 12)
      else
        local parent, name = self.program:findInput(block)
        local spec = parent and self.registry:get(parent.op).inputs[name]
        index = self.program:detachInput(block, at.X, at.Y - 12, spec and spec.default)
      end
      if not index then return end
      local script = self.program:get().scripts[index]
      x0, y0 = script.x, script.y
      holder = self.layer["Script" .. index]
      holder.ZIndex = 10
    end
    local d = (p - p0) / Theme.scale
    holder.Position = UDim2.fromOffset(math.max(0, x0 + d.X), math.max(0, y0 + d.Y) + 12)
    self:_showPreview(self:_findTarget(self:_specOfHolder(index, holder), holder))
  end, function(p)
    self.busy = false
    self.canvas.ScrollingEnabled = true
    self:_showPreview(nil)
    if not holder then
      -- a tap (no drag) on a literal field edits it
      if field and self.editor then self.editor:open(field, self.targets.fields[field]) end
      return
    end
    local target = self:_findTarget(self:_specOfHolder(index, holder), holder)
    local d = (p - p0) / Theme.scale
    if p.X < self.canvas.AbsolutePosition.X then
      self.program:removeScript(index)
    elseif not (target and self.program:attach(index, target)) then
      self.program:moveScript(index, math.max(0, x0 + d.X), math.max(0, y0 + d.Y))
    end
  end)
  return true
end

-- ---------- snapping ----------
local SNAP = 40 -- max distance (unscaled px) between the held block's connection point and a target

local function isValue(shape) return shape == "reporter" or shape == "boolean" end

-- Description of what is being held: shapes of its first/last block, block count, screen top-left and bottom-left.
function Workspace:_specOfHolder(index, holder)
  local blocks = self.program:get().scripts[index].blocks
  local first, last = self.registry:shapeOf(blocks[1]), self.registry:shapeOf(blocks[#blocks])
  local top = holder.AbsolutePosition
  -- a C-block with an empty mouth wraps what it lands on; slotPos = where that mouth's contents would start
  local wrap = self.registry:wrapSlot(blocks[1])
  local slotPos
  if wrap then
    for frame, t in pairs(self.targets.slots) do
      if t.block == blocks[1] and t.name == wrap then
        slotPos = frame.AbsolutePosition + Vector2.new(Theme.cSlotIndent * Theme.scale, 0)
        break
      end
    end
  end
  return { first = first, last = last, count = #blocks, top = top, bottom = top + Vector2.new(0, holder.AbsoluteSize.Y),
    def = self.registry:get(blocks[1].op), wrap = wrap, slotPos = slotPos }
end

-- Same, for a not-yet-placed block (palette drag): `frame` is the ghost's block frame.
function Workspace:_specOfOp(op, top, size)
  local block = self.registry:createBlock(op)
  local shape = self.registry:shapeOf(block)
  local wrap = self.registry:wrapSlot(block)
  -- the ghost has no C-slot frame yet: the mouth starts one header row down and one arm width in
  local slotPos = wrap and (top + Vector2.new(Theme.cSlotIndent * Theme.scale, Theme.rowHeight * Theme.scale)) or nil
  return { first = shape, last = shape, count = 1, top = top, bottom = top + Vector2.new(0, size.Y),
    def = self.registry:get(op), wrap = wrap, slotPos = slotPos }
end

-- Nearest compatible connection within SNAP, or nil. `exclude` = held holder (its own blocks are not targets).
function Workspace:_findTarget(drag, exclude)
  local reg, program, scale = self.registry, self.program, Theme.scale
  local best, bestD = nil, SNAP * scale
  local function skip(frame) return exclude and (frame == exclude or exclude:IsAncestorOf(frame)) end

  if isValue(drag.first) then
    if drag.count ~= 1 then return nil end
    for frame, t in pairs(self.targets.inputs) do
      local d = (frame.AbsolutePosition - drag.top).Magnitude
      if d < bestD and not skip(frame) then
        -- same rule as Validate: boolean slots take only booleans (and untyped reporters), dropdown-only slots take none
        if reg:accepts(reg:get(t.block.op), t.name, drag.first, drag.def) then
          best, bestD = { kind = "input", block = t.block, name = t.name, pos = frame.AbsolutePosition, size = frame.AbsoluteSize }, d
        end
      end
    end
    return best
  end

  for frame, block in pairs(self.blockOf) do
    if not skip(frame) then
      local shape = reg:shapeOf(block)
      if not isValue(shape) then
        local pos, size = frame.AbsolutePosition, frame.AbsoluteSize
        -- below this block (held stack goes between it and whatever follows)
        local below = Vector2.new(pos.X, pos.Y + size.Y)
        local d = (below - drag.top).Magnitude
        if d < bestD and shape ~= "cap" and drag.first ~= "hat" then
          local arr, idx = program:find(block)
          -- a held C-block wraps the blocks below the drop point, so it may go mid-stack even when its last block is a cap
          local wrapHere = (arr and idx < #arr) and drag.wrap or nil
          if arr and not (drag.last == "cap" and idx < #arr and not wrapHere) then
            best, bestD = { kind = "after", block = block, wrap = wrapHere, pos = below, size = size }, d
          end
        end
        -- on top of a script (held stack's bottom meets this script's first block)
        d = (pos - drag.bottom).Magnitude
        if d < bestD and shape ~= "hat" and drag.last ~= "cap" then
          local arr, idx, si = program:find(block)
          if arr and idx == 1 and arr == program:get().scripts[si].blocks then
            best, bestD = { kind = "before", block = block, pos = pos, size = size }, d
          end
        end
        -- a held C-block's mouth over the top of a script: it wraps the whole script
        if drag.wrap and drag.slotPos and shape ~= "hat" then
          local dw = (pos - drag.slotPos).Magnitude
          if dw < bestD then
            local arr, idx, si = program:find(block)
            if arr and idx == 1 and arr == program:get().scripts[si].blocks then
              best, bestD = { kind = "wrap", block = block, wrap = drag.wrap, pos = pos, size = size }, dw
            end
          end
        end
      end
    end
  end
  if drag.first ~= "hat" then
    for frame, t in pairs(self.targets.slots) do
      if not skip(frame) then
        local pos = frame.AbsolutePosition + Vector2.new(Theme.cSlotIndent * scale, 0)
        local d = (pos - drag.top).Magnitude
        local existing = t.block.stacks[t.name]
        local occupied = existing and #existing > 0
        local wrapHere = occupied and drag.wrap or nil -- the slot's old contents go inside the held C-block
        if d < bestD and not (drag.last == "cap" and occupied and not wrapHere) then
          best, bestD = { kind = "slot", block = t.block, name = t.name, wrap = wrapHere, pos = pos, size = Vector2.new(frame.AbsoluteSize.X - Theme.cSlotIndent * scale, 0) }, d
        end
      end
    end
  end
  return best
end

function Workspace:_showPreview(t)
  local p = self.preview
  if not t then p.Visible = false return end
  local s, origin = Theme.scale, p.Parent.AbsolutePosition
  local pos, size = t.pos, t.size
  if t.kind == "input" then
    p.BackgroundTransparency = 0.5
  else
    p.BackgroundTransparency = 0
    pos = Vector2.new(pos.X, pos.Y - 2 * s)
    size = Vector2.new(math.max(size.X, 60 * s), 4 * s)
  end
  p.Position = UDim2.fromOffset((pos.X - origin.X) / s, (pos.Y - origin.Y) / s)
  p.Size = UDim2.fromOffset(size.X / s, size.Y / s)
  p.Visible = true
end

-- Palette drag in progress: show where the ghost would snap. `frame` = the ghost's block frame.
function Workspace:hover(op, frame)
  self:_showPreview(self:_findTarget(self:_specOfOp(op, frame.AbsolutePosition, frame.AbsoluteSize)))
end

function Workspace:hoverEnd() self:_showPreview(nil) end

local function depthOf(inst)
  local d = 0
  while inst do d = d + 1; inst = inst.Parent end
  return d
end

local function isPress(input)
  local t = input.UserInputType
  return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end

-- Every block/field frame and the canvas report a press on their own. Which events fire, and in what order,
-- is not relied on: the presses for one input are gathered, then resolved once (deepest block wins, so a
-- reporter inside a stack block is grabbed instead of the block around it).
function Workspace:_press(input, kind, frame)
  if not isPress(input) then return end
  local touch = input.UserInputType == Enum.UserInputType.Touch
  -- a mouse has one left button, so a press while "busy" can only be a stale lock (button released outside the
  -- window); a touch is blocked while another finger drags
  if self.busy and touch then return end
  local key = touch and "touch" or "mouse"
  local pend = self.pending[key]
  if not pend then
    pend = { blocks = {}, fields = {} }
    self.pending[key] = pend
    task.defer(function()
      self.pending[key] = nil
      local best, bestD, field, fieldD = nil, -1, nil, -1
      for _, f in ipairs(pend.blocks) do
        local d = depthOf(f)
        if d > bestD and f.Parent then best, bestD = f, d end
      end
      for _, f in ipairs(pend.fields) do
        local d = depthOf(f)
        if d > fieldD and best and f:IsDescendantOf(best) then field, fieldD = f, d end
      end
      if self:_grab(input, best, field) then return end
      if touch then return end
      self.busy = true
      local last = Vector2.new(input.Position.X, input.Position.Y)
      Drag.track(input, function(p)
        local pos = self.canvas.CanvasPosition - (p - last) / Theme.scale
        self.canvas.CanvasPosition = Vector2.new(math.max(0, pos.X), math.max(0, pos.Y))
        last = p
      end, function() self.busy = false end)
    end)
  end
  if kind == "block" then table.insert(pend.blocks, frame)
  elseif kind == "field" then table.insert(pend.fields, frame) end
end

function Workspace:_wirePan()
  self.pending = {}
  self.canvas.InputBegan:Connect(function(input) self:_press(input, "canvas") end)
end

-- Called after every render: connects the fresh frames (old ones were destroyed with their connections).
function Workspace:_wireHits()
  for frame in pairs(self.blockOf) do
    frame.InputBegan:Connect(function(input) self:_press(input, "block", frame) end)
  end
  for frame in pairs(self.targets.fields) do
    frame.InputBegan:Connect(function(input) self:_press(input, "field", frame) end)
  end
end

function Workspace:render()
	self.layer:ClearAllChildren()
	self.blockOf = {}
	self.targets = { inputs = {}, slots = {}, fields = {} }
	local view = BlockView.new(self.registry, self.blockOf, self.targets)
	for i, script in ipairs(self.program:get().scripts) do
		local holder = Instance.new("Frame")
		holder.Name = "Script" .. i
		holder.BackgroundTransparency = 1
		holder.AutomaticSize = Enum.AutomaticSize.XY
		holder.Size = UDim2.new(0, 0, 0, 0)
		-- +12 top so a hat's curved cap (drawn above its body) stays inside the canvas
		holder.Position = UDim2.new(0, script.x, 0, script.y + 12)
		holder.Parent = self.layer
		view:buildStack(script.blocks, holder)
	end
	self:_wireHits()
	self:_applyError()
end

-- ---------- error highlight ----------
-- The block that stopped a run gets a thick outline in Theme.error. It stays until the next Run or Clear, and
-- survives re-renders (edits) as long as the block is still in the program.
function Workspace:markError(block)
	self.errorBlock = block
	self:_applyError(true)
end

function Workspace:clearError()
	if not self.errorBlock then return end
	self.errorBlock = nil
	self:render()
end

function Workspace:_applyError(reveal)
	local block = self.errorBlock
	if not block then return end
	local target
	for frame, b in pairs(self.blockOf) do
		if b == block then target = frame break end
	end
	if not target then return end
	Shapes.markError(target, Theme.error, 3)
	if reveal then
		-- AutomaticSize layout settles a frame later; then scroll the block into view if it is off-screen
		task.defer(function()
			if not target.Parent then return end
			local canvas = self.canvas
			local at, size = self:_toCanvas(target.AbsolutePosition), target.AbsoluteSize / Theme.scale
			local view = canvas.AbsoluteSize / Theme.scale
			local pos = canvas.CanvasPosition
			local nx = (at.X < pos.X or at.X + size.X > pos.X + view.X) and math.max(0, at.X - 24) or pos.X
			local ny = (at.Y < pos.Y or at.Y + size.Y > pos.Y + view.Y) and math.max(0, at.Y - 48) or pos.Y
			canvas.CanvasPosition = Vector2.new(nx, ny)
		end)
	end
end

-- `at` = screen-pixel top-left of the dropped block, `size` = its screen size; nil `at` = near the top-left of the
-- current view. A drop close to a connection snaps into it.
function Workspace:spawn(op, at, size)
  local off = (self.program:count() % 8) * 32
  local pos = at and self:_toCanvas(at) - Vector2.new(0, 12) or self.canvas.CanvasPosition + Vector2.new(24 + off, 24 + off)
  local index = self.program:addScript(self.registry:createBlock(op), math.max(0, math.floor(pos.X)), math.max(0, math.floor(pos.Y)), true)
  local target = at and size and self:_findTarget(self:_specOfOp(op, at, size))
  if not (target and self.program:attach(index, target)) then self.program:changed() end
end

return Workspace
