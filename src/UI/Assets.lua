-- Block icons, loaded from the project's GitHub repo at runtime:
--   loadasset(BASE .. path) -> "rbxasset://..."   (defined in scripts/prelude.luau, prepended by build.sh)
-- `loadasset` is for Roblox executor environments (not a Roblox API); the script still runs in Studio, without icons. When it is missing or a download fails, the icon is
-- simply left out: blocks keep working without images. Downloads run off the render path and are cached, so each
-- icon is fetched once per session however many blocks use it.
--   Assets.apply(imageLabel, "flag")   -- sets .Image when the asset is ready
local Assets = {}

Assets.BASE = "https://raw.githubusercontent.com/Horizon-Developments/scratch-luau/refs/heads/main/"

-- name -> path inside the repo (files live in assets/icons/, see assets/README.md)
Assets.PATHS = {
	flag = "assets/icons/flag.png", -- Scratch's green flag (when flag clicked)
	loop = "assets/icons/loop.png", -- Scratch's loop arrow (end of repeat / forever / ...)
}

local cache = {}   -- name -> "rbxasset://..." once loaded, false once failed
local waiting = {} -- name -> { callback, ... } while a download is running

local function loader()
	local ok, fn = pcall(function() return loadasset end)
	if ok and type(fn) == "function" then return fn end
	return nil
end

local function fetch(name, done)
	local path, load = Assets.PATHS[name], loader()
	if not path or not load then cache[name] = false; return done(nil) end
	waiting[name] = { done }
	local function work()
		local ok, result = pcall(function() return load(Assets.BASE .. path) end)
		local url = ok and type(result) == "string" and result ~= "" and result or nil
		cache[name] = url or false
		local list = waiting[name]
		waiting[name] = nil
		for _, cb in ipairs(list) do cb(url) end
	end
	if task and task.spawn then task.spawn(work) else work() end
end

-- Calls done(url) with the asset id, or done(nil) when it is unavailable. May call back later.
function Assets.get(name, done)
	local hit = cache[name]
	if hit ~= nil then return done(hit or nil) end
	if waiting[name] then table.insert(waiting[name], done) return end
	fetch(name, done)
end

function Assets.apply(imageLabel, name)
	Assets.get(name, function(url)
		if url and imageLabel.Parent then imageLabel.Image = url end
	end)
end

-- ImageLabel of `size` px for icon `name`; empty until the download finishes.
function Assets.icon(parent, name, size, order)
	local img = Instance.new("ImageLabel")
	img.Name = "Icon_" .. name
	img.BackgroundTransparency = 1
	img.BorderSizePixel = 0
	img.Size = UDim2.new(0, size, 0, size)
	img.ScaleType = Enum.ScaleType.Fit
	img.LayoutOrder = order or 0
	img.Image = ""
	img.Parent = parent
	Assets.apply(img, name)
	return img
end

return Assets
