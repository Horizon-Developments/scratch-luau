-- Block silhouettes, after scratch-blocks' renderer (zelos geometry): built from Frames because Roblox has no path
-- primitive and assets cannot be uploaded from source. Every piece has a job (DESIGN.md, Shape language):
--   stack / C / hat  connector tab under the block + matching notch in the top of the block below it, so you can see
--                    where blocks snap; a cap (no next) has no tab, a hat (no previous) has a dome instead of a notch
--   reporter         pill: round ends
--   boolean          hexagon: pointed ends
--   define hat       "bowler": rounded on all four corners
-- Colors: `color` fill, `edge` a darker outline so neighbours of one category stay separate.
local Theme = require(script.Parent.Theme)

local Shapes = {}

local function frame(parent, name, color, size, pos)
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Size = size
	if pos then f.Position = pos end
	f.Parent = parent
	return f
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius
	c.Parent = parent
	return c
end

-- Zero-size row in the block's vertical list: children positioned around it stick out above or below the block
-- without taking any layout space.
local function holder(root, name, order)
	local h = Instance.new("Frame")
	h.Name = name
	h.BackgroundTransparency = 1
	h.BorderSizePixel = 0
	h.Size = UDim2.new(0, 0, 0, 0)
	h.LayoutOrder = order
	h.Parent = root
	return h
end

-- Hexagon (pointed ends at 45 degrees) that follows `parent`'s size: a middle bar plus two rotated squares.
-- Drawn as an `edge` layer and a `fill` layer inset by the outline width. edge == nil: fill only (no outline).
-- The pieces are placed in pixels when the frame's size is known, since the point width is half its height.
function Shapes.hexagon(parent, fill, edge, order)
	local decor = Instance.new("Frame")
	decor.Name = "Hex"
	decor.BackgroundTransparency = 1
	decor.BorderSizePixel = 0
	decor.Size = UDim2.new(1, 0, 1, 0)
	decor.ZIndex = order or 1
	decor.Parent = parent

	local function layer(name, color)
		local l = Instance.new("Frame")
		l.Name = name
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		l.Parent = decor
		local mid = frame(l, "Mid", color, UDim2.new(0, 0, 0, 0))
		local left = frame(l, "Left", color, UDim2.new(0, 0, 0, 0))
		local right = frame(l, "Right", color, UDim2.new(0, 0, 0, 0))
		for _, p in ipairs({ left, right }) do
			p.AnchorPoint = Vector2.new(0.5, 0.5)
			p.Rotation = 45
		end
		return { root = l, mid = mid, left = left, right = right }
	end
	local edgeLayer = edge and layer("Edge", edge)
	local fillLayer = layer("Fill", fill)

	local function place(l, x, y, w, h)
		l.root.Position = UDim2.fromOffset(x, y)
		l.root.Size = UDim2.fromOffset(w, h)
		local half = h / 2
		local side = h / math.sqrt(2)
		l.mid.Position = UDim2.fromOffset(half, 0)
		l.mid.Size = UDim2.fromOffset(math.max(0, w - h), h)
		l.left.Size = UDim2.fromOffset(side, side)
		l.left.Position = UDim2.fromOffset(half, half)
		l.right.Size = UDim2.fromOffset(side, side)
		l.right.Position = UDim2.fromOffset(w - half, half)
	end

	local function update()
		local s = Theme.scale > 0 and Theme.scale or 1
		local w, h = decor.AbsoluteSize.X / s, decor.AbsoluteSize.Y / s
		if h <= 0 then return end
		local inset = edge and (decor:GetAttribute("Inset") or 1) or 0
		if edgeLayer then place(edgeLayer, 0, 0, w, h) end
		place(fillLayer, inset, inset, math.max(0, w - 2 * inset), math.max(0, h - 2 * inset))
	end
	decor:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
	decor:GetAttributeChangedSignal("Inset"):Connect(update)
	update()
	return decor
end

-- Styles `root` (an auto-sized Frame that is about to get its rows) as a block of `shape` and returns the Frame the
-- rows go into: root itself, or for a boolean an inner Frame above the hexagon drawn behind it.
-- opts.bowler: hat drawn as a bowler (define) hat.
function Shapes.surface(root, shape, color, edge, opts)
	opts = opts or {}
	if shape == "boolean" then
		root.BackgroundTransparency = 1
		Shapes.hexagon(root, color, edge, 1)
		local content = Instance.new("Frame")
		content.Name = "Content"
		content.BackgroundTransparency = 1
		content.BorderSizePixel = 0
		content.AutomaticSize = Enum.AutomaticSize.XY
		content.Size = UDim2.new(0, 0, 0, 0)
		content.ZIndex = 2
		content.Parent = root
		return content
	end

	root.BackgroundColor3 = color
	if shape == "reporter" then
		corner(root, UDim.new(0.5, 0))
	elseif opts.bowler then
		corner(root, Theme.bowlerRadius)
	else
		corner(root, Theme.blockRadius)
	end
	local stroke = Instance.new("UIStroke")
	stroke.Name = "Edge"
	stroke.Color = edge
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = root
	if shape == "reporter" then return root end

	local hasPrevious = shape ~= "hat"
	local hasNext = shape ~= "cap"
	local X, W, H = Theme.notchX, Theme.notchW, Theme.notchH

	if shape == "hat" and not opts.bowler then
		-- dome: a pill cut off at the block's top edge. The clip also covers the block's top outline across the dome
		-- so the two read as one piece.
		local dh = Theme.hatHeight
		local top = holder(root, "Top", 0)
		local clip = Instance.new("Frame")
		clip.Name = "Dome"
		clip.BackgroundTransparency = 1
		clip.BorderSizePixel = 0
		clip.ClipsDescendants = true
		clip.Position = UDim2.new(0, -1, 0, -(dh + 1))
		clip.Size = UDim2.new(0, Theme.hatWidth + 2, 0, dh + 1 + 4)
		clip.Parent = top
		corner(frame(clip, "Edge", edge, UDim2.new(1, 0, 0, 2 * (dh + 1)), UDim2.new(0, 0, 0, 0)), UDim.new(0.5, 0))
		corner(frame(clip, "Fill", color, UDim2.new(1, -2, 0, 2 * dh), UDim2.new(0, 1, 0, 1)), UDim.new(0.5, 0))
	elseif hasPrevious then
		-- notch: the recess the previous block's tab fills. Edge colored so it joins the outline around it.
		local top = holder(root, "Top", 0)
		corner(frame(top, "Notch", edge, UDim2.new(0, W, 0, H), UDim2.new(0, X, 0, 0)), UDim.new(0, 3))
	end

	if hasNext then
		-- tab: sticks out below the block into the next block's notch. It starts inside the block so it also hides the
		-- outline under it. Needs the block above its followers (ZIndex, see BlockView:buildStack).
		local bottom = holder(root, "Bottom", 10000)
		local e = frame(bottom, "TabEdge", edge, UDim2.new(0, W + 2, 0, H + 2), UDim2.new(0, X - 1, 0, -1))
		corner(e, UDim.new(0, 4))
		e.ZIndex = 1
		local f = frame(bottom, "Tab", color, UDim2.new(0, W, 0, H + 2), UDim2.new(0, X, 0, -2))
		corner(f, UDim.new(0, 3))
		f.ZIndex = 2
	end
	return root
end

-- The block that stopped a run: outline in `color`, `thickness` px. Works on a block root of any shape.
function Shapes.markError(block, color, thickness)
	local stroke = block:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Color = color
		stroke.Thickness = thickness
		return
	end
	local hex = block:FindFirstChild("Hex")
	if hex then
		local edge = hex:FindFirstChild("Edge")
		if edge then
			for _, piece in ipairs(edge:GetChildren()) do piece.BackgroundColor3 = color end
		end
		hex:SetAttribute("Inset", thickness)
	end
end

return Shapes
