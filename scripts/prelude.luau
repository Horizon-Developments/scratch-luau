-- Prepended to the bundle by build.sh AFTER wax + darklua, so darklua never renames it.
-- ROBLOX EXECUTOR SUPPORT: defines `loadasset(url)` for executor environments. It downloads the file once into
-- Scratch/img/ and returns its getcustomasset id. It needs executor-only functions (isfolder, makefolder, isfile,
-- writefile, getcustomasset, game:HttpGet).
-- Roblox Studio / normal game scripts: the script still runs. Those functions are missing there, so loadasset errors,
-- UI/Assets.lua pcalls it, and the flag/loop icons are simply left out. Nothing else depends on it.
local cache = {}

local function loadasset(url)
	local name = url:match("[^/]+$") -- e.g. "flag.png"
	local path = "Scratch/img/" .. name

	if cache[path] then
		return cache[path]
	end

	if not isfolder("Scratch") then makefolder("Scratch") end
	if not isfolder("Scratch/img") then makefolder("Scratch/img") end

	if not isfile(path) then
		writefile(path, game:HttpGet(url))
	end

	cache[path] = getcustomasset(path)
	return cache[path]
end
