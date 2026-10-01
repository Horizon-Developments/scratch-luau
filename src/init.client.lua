-- Entry point (LocalScript root of the bundle). Static requires only, so wax can bundle it.
-- Wires: Lang (engine + registry) -> Program (model) -> Palette + Workspace (views).
-- Step 4 adds Toolbar (Run/Stop/Clear workspace), Console (output + ask) and the interpreter wiring below.
-- Step 5 adds Save/Load (Transfer panel, JSON text) and keeps the "My Blocks" palette list in sync.
-- Step 6 adds host input for key/mouse blocks, local time for the "current" blocks, and Program.onSet upkeep.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local BlockScript = require(script.Lang)
local Theme = require(script.UI.Theme)
local Program = require(script.UI.Program)
local Palette = require(script.UI.Palette)
local Workspace = require(script.UI.Workspace)
local Editor = require(script.UI.Editor)
local Toolbar = require(script.UI.Toolbar)
local Console = require(script.UI.Console)
local Transfer = require(script.UI.Transfer)
local Plugin = require(script.Plugin)

-- Scratch:SetVisibility flips this. While false, host input (keys, mouse) registers nothing.
local visible = true

local registry = BlockScript.newRegistry()

local function B(op, inputs, stacks)
	local b = registry:createBlock(op)
	for k, v in pairs(inputs or {}) do b.inputs[k] = v end
	for k, v in pairs(stacks or {}) do b.stacks[k] = v end
	return b
end

-- Starter content so the canvas shows real blocks (hat, C-slots, nested reporters, if/else).
local program = Program.new({ scripts = {
	{ x = 24, y = 24, blocks = {
		B("events_when_run"),
		B("data_set", { NAME = "i", VALUE = 0 }),
		B("control_repeat", { TIMES = 3 }, { SUBSTACK = {
			B("data_change", { NAME = "i", BY = 1 }),
			B("out_print", { TEXT = B("op_join", { A = "i = ", B = B("data_get", { NAME = "i" }) }) }),
		} }),
	} },
	{ x = 24, y = 240, blocks = {
		B("events_when_run"),
		B("control_if_else", { COND = B("op_contains", { S = "block", T = "lock" }) }, {
			THEN = { B("out_print", { TEXT = "found" }) },
			ELSE = { B("out_print", { TEXT = "missing" }) },
		}),
	} },
} })

local gui = Instance.new("ScreenGui")
gui.Name = "BlockScript"
gui.ResetOnSpawn = false
-- Siblings stack by ZIndex within their parent only. Under Global (an executor container may default to it) a block's
-- ZIndex (set in BlockView:buildStack so earlier blocks overlap later ones) would hide its own text behind its fill.
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- On touch devices the GUI starts below Roblox's built-in top bar instead of under it: with the inset kept, the
-- ScreenGui is shorter by the bar's height, and fit() below scales the layout to that smaller area.
local function applyInset() gui.IgnoreGuiInset = not UserInputService.TouchEnabled end
applyInset()
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(applyInset)
-- Executor environments: gethui() is a hidden container game scripts do not scan. Used only when it exists AND
-- sits under a PlayerGui/CoreGui (BasePlayerGui), because dragging needs GetGuiObjectsAtPosition on that host.
-- Anywhere else (Studio, normal game scripts) the GUI goes to PlayerGui as before.
local function guiParent()
	local ok, hui = pcall(function() return type(gethui) == "function" and gethui() or nil end)
	if ok and typeof(hui) == "Instance" then
		local n = hui
		while n do
			if n:IsA("BasePlayerGui") then return hui end
			n = n.Parent
		end
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end
gui.Parent = guiParent()

local root = Instance.new("Frame")
root.Name = "Root"
root.BackgroundColor3 = Theme.ground
root.BorderSizePixel = 0
root.Parent = gui

local scale = Instance.new("UIScale")
scale.Parent = root

local function fit()
  local a = gui.AbsoluteSize
  Theme.scale = math.clamp(math.min(a.X / 1100, a.Y / 650), 0.7, 0.8)
  scale.Scale = Theme.scale
  root.Size = UDim2.fromScale(1 / Theme.scale, 1 / Theme.scale)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()

local workspaceView = Workspace.new(root, registry, program)
workspaceView.editor = Editor.new(root, registry, program)
local palette = Palette.new(root, registry,
  function(op, at, size) workspaceView:spawn(op, at, size) end,
  function(op, frame) workspaceView:hover(op, frame) end,
  function() workspaceView:hoverEnd() end)

-- Custom blocks: after any program change, make the registry match the define blocks now in the program.
local function syncCustom()
  if registry.custom.sync(program:get().scripts) then palette:refresh() end
end
program:onChanged(syncCustom)
local console -- created below with the other run wiring; onSet reports through it

-- After a literal is edited: renaming a define moves its calls and argument reporters with it, and a stop block
-- switched to a cap option drops whatever was below it into a script of its own (a cap cannot have blocks after it).
program.onSet = function(block, name, old, new)
  if block.op == "custom_define" and name == "NAME" then
    -- two defines with the same block text would make calls ambiguous: keep the old name instead
    local newCode = registry.custom.parse(tostring(new or "")).code
    if newCode ~= "" and newCode ~= registry.custom.parse(tostring(old or "")).code then
      for _, s in ipairs(program:get().scripts) do
        local first = s.blocks[1]
        if first and first ~= block and first.op == "custom_define"
          and registry.custom.parse(tostring(first.inputs.NAME or "")).code == newCode then
          block.inputs.NAME = old
          console:add("A define named \"" .. tostring(new) .. "\" already exists. Name not changed.", "error")
          return
        end
      end
    end
    registry.custom.sync(program:get().scripts) -- make sure the new call block exists before calls are pointed at it
    registry.custom.rename(program:get().scripts, block, old, new)
  end
  if registry:shapeOf(block) == "cap" then
    local arr, idx, si = program:find(block)
    if arr and arr[idx + 1] then
      local s = program:get().scripts[si]
      program:detach(arr[idx + 1], s.x + 40, s.y + 40)
    end
  end
end

-- ---------- run wiring ----------
console = Console.new(root)
local transfer = Transfer.new(root)
local toolbar

-- Scratch key names -> Roblox key codes, for "key pressed?" and "when key pressed".
local keyCodes, keyNames = {
  ["space"] = Enum.KeyCode.Space, ["up arrow"] = Enum.KeyCode.Up, ["down arrow"] = Enum.KeyCode.Down,
  ["right arrow"] = Enum.KeyCode.Right, ["left arrow"] = Enum.KeyCode.Left,
}, {}
local digitNames = { "Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine" }
for c = string.byte("a"), string.byte("z") do keyCodes[string.char(c)] = Enum.KeyCode[string.upper(string.char(c))] end
for d = 0, 9 do keyCodes[tostring(d)] = Enum.KeyCode[digitNames[d + 1]] end
for name, code in pairs(keyCodes) do keyNames[code] = name end

local interp
interp = BlockScript.newInterpreter(registry, {
  keyDown = function(name)
    if not visible then return false end
    if UserInputService:GetFocusedTextBox() then return false end -- typing in the Answer box is not a key press
    if name == "any" then
      for _, code in pairs(keyCodes) do
        if UserInputService:IsKeyDown(code) then return true end
      end
      return false
    end
    local code = keyCodes[name]
    return code ~= nil and UserInputService:IsKeyDown(code)
  end,
  mouseDown = function() return visible and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end,
  -- os.date is UTC in Roblox; Scratch's "current ..." blocks show local time
  date = function()
    local d = DateTime.now():ToLocalTime()
    return { year = d.Year, month = d.Month, day = d.Day, hour = d.Hour, min = d.Minute, sec = d.Second }
  end,
  output = function(text, kind) console:add(text, kind) end,
  clear = function() console:clear() end,
  ask = function(prompt) return console:ask(prompt) end,
  onError = function(msg, block)
    console:add("Error: " .. msg, "error")
    if block then workspaceView:markError(block) end
  end,
  onFinish = function() toolbar:setRunning(false) end,
})

UserInputService.InputBegan:Connect(function(input, processed)
  if not visible or processed or not interp.running then return end
  local name = keyNames[input.KeyCode]
  if name then interp:fire("key", name) end
end)

local function stop()
  interp:stop()
  console:cancel() -- a pending "ask" resumes with "" and the stopped script ends
end

toolbar = Toolbar.new(root, {
  onRun = function()
    console:cancel()
    workspaceView:clearError()
    console:clear() -- output always belongs to the latest run
    interp:run(program:get())
    toolbar:setRunning(interp.running)
  end,
  onStop = stop,
  onClear = function()
    stop()
    interp:resetData()
    workspaceView:clearError()
    program:clear()
  end,
  onSave = function()
    local data = { blockscript = BlockScript.Validate.VERSION, scripts = program:get().scripts }
    local ok, text = pcall(HttpService.JSONEncode, HttpService, data)
    transfer:open({
      title = "Save program",
      hint = "Copy this text and keep it. Load takes it back.",
      text = ok and text or "",
      error = ok and "" or ("Could not encode: " .. string.sub(tostring(text), 1, 120)),
      actions = { { label = "Select all", run = function(_, box)
        box:CaptureFocus()
        box.CursorPosition = #box.Text + 1
        box.SelectionStart = 1
        return true
      end } },
    })
  end,
  onLoad = function()
    transfer:open({
      title = "Load program",
      hint = "Paste saved text. Loading replaces everything in the workspace.",
      text = "",
      actions = { { label = "Replace workspace", run = function(text)
        if string.match(text, "^%s*$") then return "Paste saved text first." end
        if #text > BlockScript.Values.LIMITS.MAX_JSON_BYTES then return "Text is too large to load." end
        local ok, data = pcall(HttpService.JSONDecode, HttpService, text)
        if not ok then return "Not valid JSON: " .. string.sub(tostring(data), 1, 120) end
        local loaded, err = BlockScript.importProgram(registry, data)
        if not loaded then
          syncCustom() -- importProgram may have registered blocks the current program does not use
          return err
        end
        stop()
        interp:resetData()
        workspaceView:clearError()
        program:replace(loaded)
        return nil
      end } },
    })
  end,
})

-- ---------- Scratch object (what a loadstring of the bundle returns) ----------
-- Scratch:LoadPlugin(plugin) -> nil | error string. Scratch:SetVisibility(bool).
-- Scratch.Plugin is the Plugin class (Plugin.new({ Name = ..., Description = ... })).
local Scratch = { Plugin = Plugin, Registry = registry, Palette = palette, Program = program,
  Interpreter = interp, Gui = gui, Visible = true }

function Scratch:LoadPlugin(plugin)
  local err = BlockScript.loadPlugin(registry, plugin)
  if err ~= nil then return err end
  local ok, perr = pcall(function() palette:refresh() end)
  if not ok then return "palette refresh failed after loading plugin: " .. tostring(perr) end
  return nil
end

-- false: the GUI is hidden and registers no buttons or key/mouse input; a running program keeps running.
function Scratch:SetVisibility(on)
  assert(type(on) == "boolean", "SetVisibility expects a boolean")
  visible = on
  self.Visible = on
  gui.Enabled = on
end

return Scratch
