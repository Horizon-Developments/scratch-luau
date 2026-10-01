-- A variable reporter fits boolean slots and reads with Luau truthiness (only false and nil are false).
package.path = "tests/?.lua;" .. package.path
LISTDIR = LISTDIR or function(d) local p = io.popen("ls " .. d); local s = p:read("a"); p:close(); return s end
local H = require("harness")
local reg = H.BS.newRegistry()
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end
local getDef, ifDef = reg:get("data_get"), reg:get("control_if")
eq("var fits boolean slot", reg:accepts(ifDef, "COND", "reporter", getDef), true)
eq("plain reporter still refused", reg:accepts(ifDef, "COND", "reporter", reg:get("op_join")), false)
for _, c in ipairs({ { 1, true }, { 0, true }, { "hi", true }, { "", true }, { "false", true }, { "0", true }, { false, false } }) do
	eq("truthy " .. tostring(c[1]), H.BS.Values.toBool(c[1]), c[2])
end
print(fails == 0 and "truthy OK" or "truthy FAILED")
os.exit(fails == 0 and 0 or 1)
