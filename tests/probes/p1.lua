
local C = dofile("tests/probes/common.lua")
local reg = C.newRegistry()
local function count(t) local n=0 for _ in pairs(t) do n=n+1 end return n end
print("== P1 registry pollution across REJECTED imports")
local before = #reg.blockOrder
for i = 1, 2000 do
  local data = { blockscript=1, scripts = { { blocks = { { op = "events_when_run" }, { op = "custom:evil_"..i.." (x)" }, { op = "NOPE" } } } } }
  local p, err = C.importProgram(reg, data)
  -- what init.client does on failure: syncCustom() with the *current* program (empty here)
  reg.custom.sync({})
  if i == 1 then print("first import rejected:", p == nil, err) end
end
print("blocks before/after:", before, #reg.blockOrder, "known-unlisted still in registry:", count(reg.blocks))
local t=os.clock(); for i=1,200 do reg.custom.sync({}) end
print(string.format("cost of ONE sync({}) with %d stale entries: %.3f ms (runs on every program change)", #reg.blockOrder, (os.clock()-t)/200*1000))
print("== P1b bigger: one import with 20000 unique calls")
local blocks = { { op = "events_when_run" } }
for i = 1, 20000 do blocks[#blocks+1] = { op = "custom:u"..i } end
local t=os.clock()
local p, err = C.importProgram(reg, { scripts = { { blocks = blocks } } })
print("accepted:", p ~= nil, "registered:", #reg.blockOrder, string.format("import %.2fs", os.clock()-t))
reg.custom.sync({})
print("after sync({}) blocks still:", #reg.blockOrder)
