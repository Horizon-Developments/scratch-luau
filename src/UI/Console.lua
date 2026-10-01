-- Bottom pane: program output (monospace is allowed here only) and the answer box for "ask ... and wait".
--   local console = Console.new(root)
--   console:add(text, kind)   kind = "say" | "error" | "ask" | "input"
--   console:clear()
--   console:ask(prompt) -> string   yields the calling coroutine until Enter (host `ask` for the interpreter)
--   console:cancel()                resumes a pending ask with "" (used by Stop / Run / Clear)
local Theme = require(script.Parent.Theme)

local Console = {}
Console.__index = Console

local MAX_LINES = 500
local HEADER_H = 48
local INPUT_H = 44

local function corner(parent)
	local c = Instance.new("UICorner")
	c.CornerRadius = Theme.radius
	c.Parent = parent
end

local KIND_COLOR = {
	say = Theme.text,
	error = Theme.error,
	ask = Theme.textDim,
	input = Theme.textDim,
}

function Console.new(parent)
	local self = setmetatable({ nodes = {}, count = 0, pending = nil }, Console)

	local root = Instance.new("Frame")
	root.Name = "Console"
	root.BackgroundColor3 = Theme.panel
	root.BorderSizePixel = 0
	root.Position = UDim2.new(0, Theme.paletteWidth, 1, -Theme.consoleHeight)
	root.Size = UDim2.new(1, -Theme.paletteWidth, 0, Theme.consoleHeight)
	root.Parent = parent
	self.root = root

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(12, 0)
	title.Size = UDim2.new(0.5, 0, 0, HEADER_H)
	title.Font = Theme.font
	title.TextSize = Theme.textSize
	title.TextColor3 = Theme.textDim
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Output"
	title.Parent = root

	local clear = Instance.new("TextButton")
	clear.Name = "ClearOutput"
	clear.AutoButtonColor = false
	clear.BackgroundColor3 = Theme.ground
	clear.BorderSizePixel = 0
	clear.AnchorPoint = Vector2.new(1, 0.5)
	clear.Position = UDim2.new(1, -8, 0, HEADER_H / 2)
	clear.Size = UDim2.fromOffset(120, 44)
	clear.Font = Theme.font
	clear.TextSize = Theme.textSize
	clear.TextColor3 = Theme.text
	clear.Text = "Clear output"
	clear.Parent = root
	corner(clear)
	clear.Activated:Connect(function() self:clear() end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Lines"
	scroll.BackgroundColor3 = Theme.ground
	scroll.BorderSizePixel = 0
	scroll.Position = UDim2.fromOffset(8, HEADER_H)
	scroll.Size = UDim2.new(1, -16, 1, -HEADER_H - 8)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Theme.textDim
	scroll.Parent = root
	corner(scroll)
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft, pad.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 6), UDim.new(0, 6)
	pad.Parent = scroll
	self.scroll = scroll

	-- Answer box: only visible while a program waits for input, so it is never a dead control.
	local box = Instance.new("TextBox")
	box.Name = "Answer"
	box.Visible = false
	box.BackgroundColor3 = Theme.field
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Font = Theme.monoFont
	box.TextSize = Theme.textSize
	box.TextColor3 = Theme.fieldText
	box.PlaceholderText = "Type an answer, then Enter"
	box.PlaceholderColor3 = Theme.textDim
	box.Text = ""
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.AnchorPoint = Vector2.new(0, 1)
	box.Position = UDim2.new(0, 8, 1, -8)
	box.Size = UDim2.new(1, -16, 0, INPUT_H)
	box.Parent = root
	corner(box)
	local bp = Instance.new("UIPadding")
	bp.PaddingLeft, bp.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	bp.Parent = box
	-- accent outline = the field that is being edited (same rule as Editor)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.accent
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = box
	self.box = box
	box.FocusLost:Connect(function(enter)
		if enter then self:_submit(box.Text) end
	end)

	return self
end

function Console:_scrollToEnd()
	task.defer(function()
		self.scroll.CanvasPosition = Vector2.new(0, 1e6) -- clamped to the bottom
	end)
end

function Console:add(text, kind)
	kind = kind or "say"
	self.count += 1
	local line = Instance.new("TextLabel")
	line.Name = "Line"
	line.BackgroundTransparency = 1
	line.AutomaticSize = Enum.AutomaticSize.Y
	line.Size = UDim2.new(1, 0, 0, 0)
	line.LayoutOrder = self.count
	line.Font = Theme.monoFont
	line.TextSize = Theme.textSize
	line.TextColor3 = KIND_COLOR[kind] or Theme.text
	line.TextWrapped = true
	line.TextXAlignment = Enum.TextXAlignment.Left
	line.TextYAlignment = Enum.TextYAlignment.Top
	line.Text = tostring(text)
	line.Parent = self.scroll
	table.insert(self.nodes, line)
	if #self.nodes > MAX_LINES then
		table.remove(self.nodes, 1):Destroy()
	end
	self:_scrollToEnd()
end

function Console:clear()
	for _, n in ipairs(self.nodes) do n:Destroy() end
	self.nodes = {}
end

function Console:_showInput(on)
	self.box.Visible = on
	self.scroll.Size = on and UDim2.new(1, -16, 1, -HEADER_H - INPUT_H - 16) or UDim2.new(1, -16, 1, -HEADER_H - 8)
	if on then
		self.box.Text = ""
		self.box:CaptureFocus()
	else
		self.box:ReleaseFocus()
	end
end

function Console:_submit(text)
	local co = self.pending
	if not co then return end
	self.pending = nil
	self:_showInput(false)
	self:add("> " .. text, "input")
	task.spawn(co, text)
end

-- Called from the interpreter's run thread (inside a block's pcall); yields until the answer arrives.
function Console:ask(prompt)
	self:cancel()
	self:add(prompt, "ask")
	self.pending = coroutine.running()
	self:_showInput(true)
	return coroutine.yield()
end

function Console:cancel()
	local co = self.pending
	if not co then return end
	self.pending = nil
	self:_showInput(false)
	task.spawn(co, "")
end

return Console
