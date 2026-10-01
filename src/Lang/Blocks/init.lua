-- Block module list. STATIC requires on purpose: the wax bundler resolves them at build time.
-- To add blocks: create Blocks/MyCat.lua returning function(registry, Values) ... end,
-- then add ONE line below (order here = palette order).
return function(registry)
	local Values = require(script.Parent.Core.Values)
	local modules = {
		require(script.Events),
		require(script.Control),
		require(script.Operators),
		require(script.Variables),
		require(script.Lists),
		require(script.Sensing),
		require(script.Output),
		require(script.Custom),
	}
	for _, define in ipairs(modules) do
		define(registry, Values)
	end
end
