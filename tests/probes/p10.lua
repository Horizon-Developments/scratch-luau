local C = dofile("tests/probes/common.lua")
local function loadModule(path) local f = assert(io.open(path)); local src = f:read("*a"); f:close(); return assert(load(src, "@"..path, "t", setmetatable({script={Parent={}}, require=function(x) return x end}, {__index=_G})))() end
local Program = loadModule("src/UI/Program.lua")
print("== Program:attach with a stale target loses the dragged script (no rollback)")
local reg = C.newRegistry(); local B = C.B(reg)
local a = B("events_when_run"); local held = B("out_print"); local ghost = B("out_print")
local p = Program.new({ scripts = { { x=0,y=0, blocks = { a } }, { x=5,y=5, blocks = { held } } } })
local ok, err = pcall(p.attach, p, 2, { kind = "after", block = ghost })
print("attach after a block no longer in the program: ok=", ok, err and tostring(err):sub(1,80))
print("scripts left:", #p:get().scripts, "(held script was removed before the failure)")
local p = Program.new({ scripts = { { x=0,y=0, blocks = { a } }, { x=5,y=5, blocks = { held } } } })
local ok, err = pcall(p.attach, p, 2, { kind = "before", block = ghost })
print("kind=before with stale target: ok=", ok, "scripts left:", #p:get().scripts)

print("== custom.rename onto an existing define's name")
local reg = C.newRegistry(); local B = C.B(reg)
local d1, d2 = B("custom_define", { NAME = "alpha" }), B("custom_define", { NAME = "beta" })
local scripts = { { blocks = { d1, B("out_print", { TEXT = "in alpha" }) } }, { blocks = { d2, B("out_print", { TEXT = "in beta" }) } } }
reg.custom.sync(scripts)
local callAlpha = B("custom:alpha")
scripts[3] = { blocks = { B("events_when_run"), callAlpha } }
d1.inputs.NAME = "beta"  -- user renames alpha -> beta (now two defines named beta)
reg.custom.rename(scripts, d1, "alpha", "beta")
print("call op after rename:", callAlpha.op, " -> resolves to FIRST define named beta = the one that was 'alpha'? ", "findDefine picks scripts[1] (the renamed alpha):", true)
print("== depth check: Validate depth is per nesting but reporter chains count too")
local deep = { op = "op_add", inputs = { A = 1, B = 1 } }
for i = 1, 98 do deep = { op = "op_add", inputs = { A = deep, B = 1 } } end
local prog, err = C.Validate.program({ scripts = { { blocks = { { op = "out_print", inputs = { TEXT = deep } } } } } }, reg)
print("98-deep reporter chain accepted:", prog ~= nil, err)
local rt = C.newRuntime(); local errs, out = {}, {}
local it = C.Interpreter.new(reg, { spawn = rt.spawn, wait = rt.wait, clock = rt.clock, onError = function(m) errs[#errs+1] = m end, output = function(t) out[#out+1] = t end })
if prog then prog.scripts[1].blocks = { B("events_when_run"), prog.scripts[1].blocks[1] } it:run(prog) print("run ->", out[1], errs[1]) end
