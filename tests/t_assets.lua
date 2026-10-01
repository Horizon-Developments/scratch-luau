-- Icons: label token {@name}, footerIcon, and Assets loading (fake loadasset / HttpGetAsync, no network).
package.path = "tests/?.lua;" .. package.path
LISTDIR = LISTDIR or function(d) local p = io.popen("ls " .. d); local s = p:read("a"); p:close(); return s end
local M = require("ui_mock")
local H = require("harness")
local tree, load_ = M.loader("src/UI", function(d) local t = {} for f in string.gmatch(LISTDIR(d), "[^\n]+") do t[#t + 1] = f end return t end)
local Assets = load_(tree.Assets)
local BlockView = load_(tree.BlockView)
local fails = 0
local function eq(name, got, want)
	if got ~= want then fails = fails + 1; print("FAIL", name, "got", tostring(got), "want", tostring(want)) else print("ok  ", name) end
end

local reg = H.BS.newRegistry()
local hat = reg:get("events_when_run")
eq("flag segment", hat.segments[2] and hat.segments[2].icon, "flag")
eq("label text kept", hat.segments[1].text, "when ")
eq("loop on repeat", reg:get("control_repeat").footerIcon, "loop")
eq("loop on forever", reg:get("control_forever").footerIcon, "loop")
eq("no loop on if", reg:get("control_if").footerIcon, nil)

-- without loadasset: block renders, icon frames exist and stay empty
local function icons(root) return M.find(root, function(n) return n.ClassName == "ImageLabel" end) end
local host = Instance.new("Frame")
local view = BlockView.new(reg, {}, nil)
local f = view:build(reg:createBlock("events_when_run"), host)
local found = icons(f)
eq("flag icon built", #found, 1)
eq("empty without loadasset", found[1].Image, "")

local rep = view:build(reg:createBlock("control_repeat"), host)
eq("loop icon in footer", #icons(rep), 1)
eq("icon sits in Footer", icons(rep)[1].Parent.Name, "Footer")

-- with a fake loader: image set, each path fetched once
local fetched = {}
game = {}
loadasset = function(url) fetched[#fetched + 1] = url return "rbxasset://fake/" .. #fetched end
package.loaded.Assets = nil
local tree2, load2 = M.loader("src/UI", function(d) local t = {} for f in string.gmatch(LISTDIR(d), "[^\n]+") do t[#t + 1] = f end return t end)
local A2 = load2(tree2.Assets)
local img = Instance.new("ImageLabel"); img.Parent = host
A2.apply(img, "flag")
eq("image set", img.Image, "rbxasset://fake/1")
local img2 = Instance.new("ImageLabel"); img2.Parent = host
A2.apply(img2, "flag")
eq("cached: one download", #fetched, 1)
eq("url built from BASE", fetched[1], A2.BASE .. "assets/icons/flag.png")
eq("both labels set", img2.Image, "rbxasset://fake/1")
-- failing download: no image, no error
loadasset = function() error("http 404") end
local img3 = Instance.new("ImageLabel"); img3.Parent = host
A2.apply(img3, "loop")
eq("failed download leaves image empty", img3.Image == nil or img3.Image == "", true)
print(fails == 0 and "assets OK" or ("assets FAILED " .. fails))
os.exit(fails == 0 and 0 or 1)
