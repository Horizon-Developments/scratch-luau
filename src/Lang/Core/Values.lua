-- Scratch-style value coercion. Pure Lua (no Roblox APIs).
local Values = {}

-- Shared limits (single source). Engine, import validation and UI all read this table.
-- FRAME_WINDOW and MAX_LINES_PER_FRAME were added by the engine slice (see CACHE.md).
Values.LIMITS = {
	MAX_THREADS = 200,            -- live threads per run
	MAX_STARTS_PER_FRAME = 50,    -- thread starts per frame by broadcast / key / poll (the initial Run start is exempt)
	FRAME_SECONDS = 0.008,        -- total CPU per frame shared by ALL threads (time-sliced via clock)
	FRAME_WINDOW = 0.015,         -- clock span treated as one frame (below 1/60 s so a 60 Hz frame always opens a new window)
	WARP_SECONDS = 0.5,           -- longest a warp body runs before it yields one frame (Scratch's value)
	MAX_STRING = 1000000,         -- bytes for any string value produced at runtime
	MAX_LIST = 200000,            -- items per list
	MAX_LISTS_TOTAL_ITEMS = 1000000, MAX_VARS = 1000, MAX_LISTS = 200,
	MAX_PRINT = 10000,            -- chars per print line
	MAX_LINES_PER_FRAME = 100,    -- print lines per frame before output is throttled
	MAX_EXEC_DEPTH = 3000,        -- nested execBlock frames (blocks run without pcall, so this only guards the Lua stack)
	MAX_CALL_DEPTH = 500,         -- nested My Block calls (recursion depth)
	MAX_SCRIPTS = 1000, MAX_BLOCKS = 20000,   -- imported program totals (all nodes incl. reporters)
	MAX_JSON_BYTES = 1000000,     -- checked in init.client Load handler BEFORE JSONDecode
	MAX_NAME = 200, MAX_PARAMS = 16, MAX_CUSTOM = 500, -- MAX_CUSTOM: distinct My Block calls one program may register
	 MAX_LITERAL = 10000, MAX_DEPTH = 100,
}
local LIMITS = Values.LIMITS

-- Luau's type names for error messages.
function Values.typeName(v)
	if v == nil then return "nil" end
	return type(v)
end

-- Text -> number the way Luau tonumber() reads it: surrounding spaces ignored, 0x hex, exponents; "", "inf", "nan"
-- and hex floats are not numbers. Returns nil when the text is not a number.
function Values.parseNumber(s)
	local t = string.match(s, "^%s*(.-)%s*$")
	if t == "" or string.find(t, "[nNpP]") then return nil end
	local n = tonumber(t)
	if n == nil or n ~= n then return nil end
	return n + 0.0
end

-- Number for a number slot / arithmetic, like Luau: numbers pass, numeric text is converted ("5" + 1 = 6),
-- anything else (nil, boolean, other text) is an error instead of a silent 0.
function Values.toNumber(v)
	if type(v) == "number" then return v + 0.0 end
	if type(v) == "string" then
		local n = Values.parseNumber(v)
		if n ~= nil then return n end
	end
	error("expected a number, got " .. (type(v) == "string" and "text \"" .. string.sub(v, 1, 20) .. "\"" or Values.typeName(v)), 0)
end

-- Returns s unchanged, or errors "string too long" (runtime string values are capped at MAX_STRING bytes).
function Values.limitString(s)
	if type(s) == "string" and #s > LIMITS.MAX_STRING then error("string too long", 0) end
	return s
end

-- Luau tostring: numbers use %.14g (0.1 + 0.2 -> 0.3, 1e15 -> 1e+15), nil is "nil", inf / nan like Luau.
function Values.toString(v)
	if type(v) == "number" then
		if v ~= v then return "nan" end
		if v == math.huge then return "inf" end
		if v == -math.huge then return "-inf" end
		return string.format("%.14g", v)
	end
	return tostring(v)
end

-- Luau math.round: halves round away from zero (2.5 -> 3, -2.5 -> -3).
function Values.round(x)
	if x >= 0 then return math.floor(x + 0.5) end
	return -math.floor(-x + 0.5)
end

-- Characters of a string as a list (UTF-8 aware; invalid UTF-8 falls back to bytes). Allocates: blocks use
-- Values.length / Values.letter instead.
function Values.chars(s)
	local out = {}
	if utf8 and utf8.len(s) then
		for ch in string.gmatch(s, utf8.charpattern) do out[#out + 1] = ch end
	else
		for i = 1, #s do out[i] = string.sub(s, i, i) end
	end
	return out
end

-- Number of characters, without allocating (invalid UTF-8 counts bytes).
function Values.length(s)
	return (utf8 and utf8.len(s)) or #s
end

-- The n-th character (n is a whole number), or "" when out of range. No per-call tables.
function Values.letter(s, n)
	local len = Values.length(s)
	if n ~= n or n < 1 or n > len then return "" end
	if utf8 and utf8.len(s) then
		local a = utf8.offset(s, n)
		local b = utf8.offset(s, n + 1)
		return string.sub(s, a, (b or #s + 1) - 1)
	end
	return string.sub(s, n, n)
end

-- List index rules: a whole number inside 1..length (Luau t[i]; t[1.5] and t["1"] are nil), plus the words
-- last / random (or any) / all (delete only). `length` is the size the index is checked against (callers pass
-- #list + 1 for insert). Returns an integer 1..length, "all" (only when acceptAll), or nil when invalid.
function Values.listIndex(index, length, acceptAll)
	if type(index) == "string" then
		if index == "all" then return acceptAll and "all" or nil end
		if index == "last" then return length > 0 and length or nil end
		if index == "random" or index == "any" then return length > 0 and math.random(1, length) or nil end
		return nil
	end
	if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > length then return nil end
	return math.floor(index)
end

-- Luau truthiness: only false and nil are false. 0, "" and "0" are true.
function Values.toBool(v)
	return v ~= nil and v ~= false
end

-- Luau ==: no conversion, case-sensitive, so 1 == "1" is false (use tonumber / tostring to convert).
function Values.equals(a, b) return a == b end

-- Luau <: two numbers or two strings (byte order). Anything else is an error, like "attempt to compare number with string".
function Values.less(a, b)
	local ta, tb = type(a), type(b)
	if ta == tb and (ta == "number" or ta == "string") then return a < b end
	error("attempt to compare " .. Values.typeName(a) .. " with " .. Values.typeName(b), 0)
end

-- A list as one text value (Scratch): items joined with "" when every item is a single character, else with " ".
function Values.listContents(list)
	local single = true
	for _, v in ipairs(list) do
		if not (type(v) == "string" and Values.length(v) == 1) then single = false break end
	end
	local parts, total = {}, 0
	for i, v in ipairs(list) do
		local t = Values.toString(v)
		total = total + #t + 1
		if total > LIMITS.MAX_STRING then error("string too long", 0) end
		parts[i] = t
	end
	return table.concat(parts, single and "" or " ")
end

-- Key names for key blocks (Scratch's list and order): the host maps its own key codes to these names.
Values.KEYS = { "space", "up arrow", "down arrow", "right arrow", "left arrow", "any" }
for c = string.byte("a"), string.byte("z") do table.insert(Values.KEYS, string.char(c)) end
for d = 0, 9 do table.insert(Values.KEYS, tostring(d)) end

-- Coerce by input type name ("number","string","boolean","variable","list","param","any").
function Values.coerce(kind, v)
	if kind == "number" then return Values.toNumber(v) end
	if kind == "string" or kind == "variable" or kind == "list" or kind == "param" then return Values.toString(v) end
	if kind == "boolean" then return Values.toBool(v) end
	return v
end

return Values
