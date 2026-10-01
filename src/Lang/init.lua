-- BlockScript facade. Usage:
--   local BS = require(script.Lang)
--   local registry = BS.newRegistry()
--   local interp = BS.newInterpreter(registry, { output = function(text, kind) end })
--   interp:run(program)
local Registry = require(script.Core.Registry)
local Interpreter = require(script.Core.Interpreter)
local Values = require(script.Core.Values)
local Validate = require(script.Core.Validate)
local Plugins = require(script.Core.Plugins)

local BlockScript = { Registry = Registry, Interpreter = Interpreter, Values = Values, Validate = Validate, Plugins = Plugins }

function BlockScript.newRegistry()
	local r = Registry.new()
	require(script.Blocks)(r)
	return r
end

function BlockScript.newInterpreter(registry, opts) return Interpreter.new(registry, opts) end

-- Untrusted decoded data -> clean Program, or (nil, err). Registers any custom blocks the data uses first.
-- Afterwards call registry.custom.sync(program scripts) so the palette list matches the program actually in use.
function BlockScript.importProgram(registry, data)
	local sizeErr = Validate.checkSize(data) -- before registering anything for hostile data
	if sizeErr then return nil, sizeErr end
	if registry.custom then registry.custom.sync(type(data) == "table" and data.scripts or nil, true) end
	return Validate.program(data, registry)
end

-- Registers a Plugin object's categories and blocks. Returns nil, or an error string (nothing stays registered).
-- The caller refreshes the palette on success (Scratch:LoadPlugin does).
function BlockScript.loadPlugin(registry, plugin) return Plugins.load(registry, plugin) end

return BlockScript
