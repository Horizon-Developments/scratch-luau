-- Modal text panel for Save (copy text out) and Load (paste text in). Studio has no file dialog, so the program
-- travels as text.
--   local t = Transfer.new(root)
--   t:open({ title, hint, text, error, actions = { { label, run = function(text, box) -> nil | string | true end } } })
-- run result: nil = close the panel, string = show it as an error and stay open, true = stay open.
-- A Close button is always present. Only Close dismisses it (tapping outside does nothing), so pasted text is
-- never lost to a stray tap.
local Theme = require(script.Parent.Theme)

local Transfer = {}
Transfer.__index = Transfer

local PANEL_W, PANEL_H = 560, 380

local function corner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = Theme.radius
	c.Parent = parent
end

local function label(parent, text, y, h, color, wrapped)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Position = UDim2.fromOffset(16, y)
	l.Size = UDim2.new(1, -32, 0, h)
	l.Font = Theme.font
	l.TextSize = Theme.textSize
	l.TextColor3 = color
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Top
	l.TextWrapped = wrapped or false
	l.Text = text
	l.Parent = parent
	return l
end

function Transfer.new(parent)
	return setmetatable({ parent = parent }, Transfer)
end

function Transfer:close()
	if self.layer then
		self.layer:Destroy()
		self.layer = nil
	end
end

function Transfer:open(opts)
	self:close()
	-- Full-cover button: sinks input so the workspace underneath cannot be dragged while the panel is open.
	local layer = Instance.new("TextButton")
	layer.Name = "TransferLayer"
	layer.BackgroundTransparency = 1
	layer.Text = ""
	layer.AutoButtonColor = false
	layer.Size = UDim2.fromScale(1, 1)
	layer.ZIndex = 400
	layer.Parent = self.parent
	self.layer = layer

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.BackgroundColor3 = Theme.panel
	panel.BorderSizePixel = 0
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	-- centered over the workspace area (right of the palette)
	panel.Position = UDim2.new(0.5, Theme.paletteWidth / 2, 0.5, 0)
	panel.Size = UDim2.fromOffset(PANEL_W, PANEL_H)
	panel.Parent = layer
	corner(panel)
	-- 1px outline separates the panel from the same-colored palette/canvas behind it (functional)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.textDim
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = panel

	label(panel, opts.title or "", 10, 24, Theme.text)
	label(panel, opts.hint or "", 36, 20, Theme.textDim)

	local box = Instance.new("TextBox")
	box.Name = "Text"
	box.BackgroundColor3 = Theme.field
	box.BorderSizePixel = 0
	box.Position = UDim2.fromOffset(16, 64)
	box.Size = UDim2.new(1, -32, 0, 212)
	box.MultiLine = true
	box.TextWrapped = true
	box.ClearTextOnFocus = false
	box.Font = Theme.font
	box.TextSize = Theme.textSize
	box.TextColor3 = Theme.fieldText
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextYAlignment = Enum.TextYAlignment.Top
	box.Text = opts.text or ""
	box.Parent = panel
	corner(box)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight, pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = box

	-- error line: Theme.error is the status color (DESIGN.md), used here only for a failed load/save
	local err = label(panel, opts.error or "", 282, 34, Theme.error, true)

	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Position = UDim2.new(0, 16, 1, -56)
	row.Size = UDim2.new(1, -32, 0, 44)
	row.Parent = panel
	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = row

	local function button(text, width, order, onPress)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.BackgroundColor3 = Theme.ground
		b.BorderSizePixel = 0
		b.Size = UDim2.fromOffset(width, 40) -- 40px touch target
		b.LayoutOrder = order
		b.Font = Theme.font
		b.TextSize = Theme.textSize
		b.TextColor3 = Theme.text
		b.Text = text
		b.Parent = row
		corner(b)
		b.Activated:Connect(onPress)
	end

	for i, action in ipairs(opts.actions or {}) do
		button(action.label, 176, i, function()
			local result = action.run(box.Text, box)
			if result == nil then
				self:close()
			elseif type(result) == "string" then
				err.Text = result
			else
				err.Text = ""
			end
		end)
	end
	button("Close", 96, 100, function() self:close() end)
end

return Transfer
