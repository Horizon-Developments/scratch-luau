package.path = "tests/?.lua;" .. package.path
local H = require("harness")
local V = H.BS.Values
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) end
end
-- tostring: Luau %.14g
eq("0.1+0.2", V.toString(0.1 + 0.2), "0.3")
eq("1/3", V.toString(1 / 3), "0.33333333333333")
eq("0.5", V.toString(0.5), "0.5")
eq("-2.5", V.toString(-2.5), "-2.5")
eq("1e21", V.toString(1e21), "1e+21")
eq("1e15", V.toString(1e15), "1e+15")
eq("int", V.toString(42.0), "42")
eq("inf", V.toString(math.huge), "inf")
eq("-inf", V.toString(-math.huge), "-inf")
eq("nil", V.toString(nil), "nil")
eq("true", V.toString(true), "true")
-- equality: strict, like ==
eq("1 == '1'", V.equals(1, "1"), false)
eq("'a' == 'A'", V.equals("a", "A"), false)
eq("true == 1", V.equals(true, 1), false)
eq("2 == 2.0", V.equals(2, 2.0), true)
eq("'x' == 'x'", V.equals("x", "x"), true)
-- tonumber / arithmetic coercion
local function errs(f, ...) local ok = pcall(f, ...) return not ok end
eq("' 5 '", V.toNumber(" 5 "), 5)
eq("0x10", V.toNumber("0x10"), 16)
eq("1e3", V.toNumber("1e3"), 1000)
eq("5.", V.toNumber("5."), 5)
eq("abc errors", errs(V.toNumber, "abc"), true)
eq("inf text errors", errs(V.toNumber, "inf"), true)
eq("nan text errors", errs(V.toNumber, "nan"), true)
eq("blank errors", errs(V.toNumber, ""), true)
eq("nil errors", errs(V.toNumber, nil), true)
eq("true errors", errs(V.toNumber, true), true)
eq("parseNumber abc", V.parseNumber("abc"), nil)
-- comparison
eq("1 < 2", V.less(1, 2), true)
eq("'a' < 'b'", V.less("a", "b"), true)
eq("'B' < 'a' (bytes)", V.less("B", "a"), true)
eq("'10' < '9' (text)", V.less("10", "9"), true)
eq("number < text errors", errs(V.less, 1, "2"), true)
eq("nil < 1 errors", errs(V.less, nil, 1), true)
-- truthiness
for _, c in ipairs({ { 0, true }, { "", true }, { "0", true }, { "false", true }, { 1, true }, { false, false }, { true, true } }) do
	eq("truthy " .. tostring(c[1]), V.toBool(c[1]), c[2])
end
eq("nil falsy", V.toBool(nil), false)
-- round: half away from zero
eq("round 2.5", V.round(2.5), 3)
eq("round -2.5", V.round(-2.5), -3)
eq("round -2.4", V.round(-2.4), -2)
-- list index: whole numbers only
eq("idx 1", V.listIndex(1, 3), 1)
eq("idx 1.5", V.listIndex(1.5, 3), nil)
eq("idx '1' text", V.listIndex("1", 3), nil)
eq("idx 0", V.listIndex(0, 3), nil)
eq("idx 4", V.listIndex(4, 3), nil)
eq("idx last", V.listIndex("last", 3), 3)
eq("idx all (delete)", V.listIndex("all", 3, true), "all")
print(fails == 0 and "values OK" or (fails .. " FAILED"))
