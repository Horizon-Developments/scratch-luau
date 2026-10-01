-- UI constants. Two neutrals (ground, panel) + ONE accent (selection / Run). Category colors come from the Registry.
-- Field colors are functional: a light field with dark text marks "you can type here".
local Theme = {
	ground = Color3.fromRGB(28, 30, 34),   -- workspace canvas
	panel = Color3.fromRGB(42, 45, 51),    -- palette + tab column
	text = Color3.fromRGB(235, 237, 240),  -- text on neutrals
	textDim = Color3.fromRGB(160, 165, 174),
	accent = Color3.fromRGB(76, 139, 245), -- selection + Run button
	error = Color3.fromRGB(244, 120, 120),   -- status only: the block that stopped a run, and error lines in the console
	field = Color3.fromRGB(246, 246, 246), -- input field fill
	fieldText = Color3.fromRGB(30, 32, 36),

	font = Enum.Font.GothamMedium,
	blockFont = Enum.Font.GothamBold, -- text printed on blocks (Scratch prints bold labels)
	whiteBlockText = false, -- true = white text on every block like Scratch; false = whichever of white / dark reads better
	monoFont = Enum.Font.Code, -- console output only
	textSize = 14,
	radius = UDim.new(0, 4),
	blockRadius = UDim.new(0, 5),     -- stack / C / cap blocks
	bowlerRadius = UDim.new(0, 14),   -- My Blocks define hat: rounded on all four corners (Scratch's bowler hat)
	reporterRadius = UDim.new(0, 10), -- reporter = rounded ends (DESIGN.md)
	booleanRadius = UDim.new(0, 2),   -- boolean = squarer ends, wider side padding (DESIGN.md)

	-- block silhouette (see DESIGN.md, Shape language): connector tab under a block, matching notch in the top of the next
	notchX = 14,         -- tab / notch distance from the block's left edge
	notchW = 28,
	notchH = 6,          -- how far the tab sticks out below the block
	hatHeight = 18,      -- dome height above a hat block
	hatWidth = 88,
	rowHeight = 40,      -- min block row height; with 4px holder padding gives the 44px touch target (R-03)
	pad = 8,             -- horizontal block padding
	gap = 6,             -- gap between segments in a row
	cSlotIndent = 16,    -- C-slot left arm width
	cSlotMinHeight = 24, -- empty C-slot height
	cFooter = 10,        -- bottom arm of a C block
	cFooterIcon = 24,    -- bottom arm of a C block that carries an icon (loop arrow)
	iconSize = 20,       -- Scratch block icons (flag, loop arrow)
	paletteWidth = 320,
	tabWidth = 96,
	tabHeight = 44,
	toolbarHeight = 56,
	consoleHeight = 184, -- header row (48) + output lines
  scale = 1, -- set by init.client.lua from viewport size
}

function Theme.categoryColor(cat)
	local c = cat and cat.color or { 150, 150, 150 }
	return Color3.fromRGB(c[1], c[2], c[3])
end

-- Darker edge color so adjacent blocks of the same category stay readable (functional separation).
-- Scaling R, G and B by 0.7 is the same as scaling HSV value by 0.7 (hue and saturation unchanged), without needing HSV calls.
function Theme.edge(color)
	return Color3.new(color.R * 0.78, color.G * 0.78, color.B * 0.78)
end

-- Dropdown field fill: a much darker shade of the block, so white text on it reads (>= 4.5:1 on every category).
function Theme.dropdown(color)
	return Color3.new(color.R * 0.5, color.G * 0.5, color.B * 0.5)
end

-- Relative luminance (WCAG) of a Color3.
local function luminance(c)
	local function f(v) return v <= 0.03928 and v / 12.92 or ((v + 0.055) / 1.055) ^ 2.4 end
	return 0.2126 * f(c.R) + 0.7152 * f(c.G) + 0.0722 * f(c.B)
end
Theme.luminance = luminance

-- Text color for text printed on `color`: the dark field text or white, whichever has the higher contrast
-- (unless whiteBlockText forces white, Scratch's look).
function Theme.textOn(color)
	if Theme.whiteBlockText then return Color3.new(1, 1, 1) end
	local l = luminance(color)
	local white = 1.05 / (l + 0.05)
	local dark = (l + 0.05) / (luminance(Theme.fieldText) + 0.05)
	return white > dark and Color3.new(1, 1, 1) or Theme.fieldText
end

-- Empty boolean slot: a darker recess of the block it sits in.
function Theme.recess(color)
	return Color3.new(color.R * 0.6, color.G * 0.6, color.B * 0.6)
end

return Theme
