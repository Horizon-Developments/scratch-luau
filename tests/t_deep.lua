package.path = "tests/?.lua;" .. package.path
local H = require("harness")
local b, script, prog = H.b, H.script, H.prog
local T = H.new()
local def = script(b("custom_define", { NAME = "count (n)", MODE = "normal" }),
	b("control_if", { COND = b("op_gt", { A = b("custom_arg", { NAME = "n" }), B = 0 }) }, { THEN = {
		b("data_change", { NAME = "x", BY = 1 }),
		b("custom:count %s", { P1 = b("op_sub", { A = b("custom_arg", { NAME = "n" }), B = 1 }) }) } }))
local main = script(b("events_when_run"), b("data_set", { NAME = "x", VALUE = 0 }), b("custom:count %s", { P1 = 499 }))
local p = prog(main, def); T.reg.custom.sync(p.scripts); T.interp:run(p)
T.S.run(3000, function() return not T.interp.running end)
print("x =", T.interp.vars.x, "errors:", #T.errs, T.errs[1] and T.errs[1][1])
