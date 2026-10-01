-- Top bar over the workspace: Run (accent), Stop, Clear workspace, Save, Load. Every button works.
--   local bar = Toolbar.new(root, { onRun = fn, onStop = fn, onClear = fn, onSave = fn, onLoad = fn })
--   bar:setRunning(bool)   -- Stop is dimmed while nothing runs
local Theme = require(script.Parent.Theme)

local Toolbar = {}
Toolbar.__index = Toolbar

local CONFIRM_SECONDS = 3

local function button(parent, name, text, width, fill, textColor, order)
	local b = Instance.new("TextButton")
	b.Name = name
	b.AutoButtonColor = false
	b.BackgroundColor3 = fill
	b.BorderSizePixel = 0
	b.Size = UDim2.fromOffset(width, 44) -- 44px touch target
	b.LayoutOrder = order
	b.Font = Theme.font
	b.TextSize = Theme.textSize
	b.TextColor3 = textColor
	b.Text = text
	b.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = Theme.radius
	c.Parent = b
	return b
end

function Toolbar.new(parent, handlers)
	local self = setmetatable({ handlers = handlers, confirmToken = 0 }, Toolbar)

	local bar = Instance.new("Frame")
	bar.Name = "Toolbar"
	bar.BackgroundColor3 = Theme.panel
	bar.BorderSizePixel = 0
	bar.Position = UDim2.new(0, Theme.paletteWidth, 0, 0)
	bar.Size = UDim2.new(1, -Theme.paletteWidth, 0, Theme.toolbarHeight)
	bar.Parent = parent
	self.bar = bar

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 8)
	list.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.Parent = bar

	-- Run is the one accent-filled control (DESIGN.md: accent = Run + selection)
	self.run = button(bar, "Run", "Run", 96, Theme.accent, Theme.fieldText, 1)
	self.stop = button(bar, "Stop", "Stop", 96, Theme.ground, Theme.textDim, 2)
	self.clear = button(bar, "ClearWorkspace", "Clear workspace", 152, Theme.ground, Theme.text, 3)

	self.save = button(bar, "Save", "Save", 88, Theme.ground, Theme.text, 4)
	self.load = button(bar, "Load", "Load", 88, Theme.ground, Theme.text, 5)

	self.run.Activated:Connect(function()
		self:_resetClear()
		handlers.onRun()
	end)
	self.stop.Activated:Connect(function()
		self:_resetClear()
		handlers.onStop()
	end)
	self.save.Activated:Connect(function()
		self:_resetClear()
		handlers.onSave()
	end)
	self.load.Activated:Connect(function()
		self:_resetClear()
		handlers.onLoad()
	end)
	-- Clear workspace deletes every script, so it needs a second tap within CONFIRM_SECONDS.
	self.clear.Activated:Connect(function()
		if self.confirming then
			self:_resetClear()
			handlers.onClear()
			return
		end
		self.confirming = true
		self.clear.Text = "Tap again to delete all"
		self.clear.TextColor3 = Theme.error
		self.confirmToken += 1
		local token = self.confirmToken
		task.delay(CONFIRM_SECONDS, function()
			if self.confirmToken == token then self:_resetClear() end
		end)
	end)
	return self
end

function Toolbar:_resetClear()
	self.confirmToken += 1
	self.confirming = false
	self.clear.Text = "Clear workspace"
	self.clear.TextColor3 = Theme.text
end

function Toolbar:setRunning(running)
	self.stop.TextColor3 = running and Theme.text or Theme.textDim
end

return Toolbar
